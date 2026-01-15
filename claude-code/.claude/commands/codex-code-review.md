# Codex Code Review

Get a comprehensive code review from OpenAI Codex with validated, refined feedback. Uses a subagent to iterate with Codex and filter out invalid suggestions before presenting to you.

**Scopes:**
- `all` - Review all changes (untracked + unstaged + staged)
- `uncommitted` - Review untracked + unstaged only (ignore staged)
- `staged` - Review staged changes only (what would be committed)
- `branch [base]` - Review current branch vs base (default: master). Requires clean working directory.
- `pr <number>` - Review a specific PR

**Flags:**
- `--no-context` - Skip context gathering for a "blind" review

**Smart default:** If no scope given, detects feature branch → `branch`, otherwise → `all`

---

## Step 1: Parse Scope and Flags from Arguments

Parse `$ARGUMENTS` to determine scope and flags:

```
$ARGUMENTS = "$ARGUMENTS"
```

**Flag detection:**
- Check for `--no-context` flag anywhere in arguments
- Remove flag from arguments before parsing scope

**Scope detection logic:**
1. If starts with `all` → scope = all
2. If starts with `uncommitted` → scope = uncommitted
3. If starts with `staged` → scope = staged
4. If starts with `branch` → scope = branch, parse optional base (default: master)
5. If starts with `pr` → scope = pr, parse PR number (required)
5. If empty → smart default:
   - Run `git branch --show-current`
   - If not `master` or `main` → scope = branch (base = master)
   - Else → scope = all

## Step 2: Validate Scope (Minimal - No Diffs!)

**IMPORTANT: Do NOT run git diff or fetch any diff content. That pollutes your context.**

### For scope = `branch`
Only check for dirty working directory:
```bash
git status --porcelain
```
If output is non-empty, ABORT with:
> "Working directory has uncommitted changes. Please commit or stash first, or use `all`/`uncommitted` scope to review working directory changes."

### For all other scopes
No validation needed. Proceed to context gathering.

## Step 3: Gather Context (unless --no-context)

**Skip this step if `--no-context` flag was provided.**

Gather context to help Codex understand the INTENT of changes (do NOT fetch diffs!):

1. **Plan file path**: Check if you're in plan mode or have a plan file in context. Note the PATH only - don't read the content. Each agent will read it themselves if needed.

2. **Supplementary context**: From your conversation, extract relevant info that is NOT in the plan file:
   - Specific user concerns mentioned
   - Design decisions discussed verbally
   - Areas of uncertainty
   - Constraints or requirements mentioned but not documented

   Scale detail to the task size - bigger task = more detail is appropriate.

Store these as:
- `[PLAN_FILE_PATH]` - Path to plan file, or "none"
- `[SUPPLEMENTARY_CONTEXT]` - Additional context from conversation, or "none"

## Step 4: Spawn Subagent

Use the Task tool to spawn a subagent. **Do NOT pass any diff content** - only pass scope and context. The subagent will instruct Codex to fetch its own diffs.

Pass the following prompt VERBATIM (fill in placeholders):

---

You are a code review assistant. Your job is to get feedback on code changes from OpenAI Codex, **validate and refine** that feedback, then return actionable results.

### CRITICAL RULES

1. **READ-ONLY** - Codex runs with `--sandbox read-only`. You may read files to verify claims but make NO changes.
2. **VALIDATE FEEDBACK** - Don't just relay Codex's feedback. Challenge vague or questionable points.
3. **ITERATE** - Keep conversing with Codex until feedback is complete and validated.
4. **ACTIONABLE OUTPUT** - Return structured feedback that an AI agent could act on.
5. **CODEX FETCHES CONTEXT** - Codex will run git commands itself to get the diff. Do NOT fetch diffs yourself.

### Scope

**Scope:** [SCOPE]
**Base (if branch scope):** [BASE]

### Context

**Plan file path:** [PLAN_FILE_PATH]
If a path is provided, you and Codex can read this file to understand the intent of the changes. Don't just blindly accept feedback that contradicts the plan.

**Supplementary context:** [SUPPLEMENTARY_CONTEXT]
This is additional relevant information from the main conversation that isn't in the plan file.

**Git commands Codex should run based on scope:**
- `all`: `git diff` (unstaged) + `git diff --cached` (staged) + `git ls-files --others --exclude-standard` (untracked)
- `uncommitted`: `git diff` (unstaged) + `git ls-files --others --exclude-standard` (untracked)
- `staged`: `git diff --cached`
- `branch [base]`: `git diff [base]...HEAD` + `git log [base]...HEAD --oneline`
- `pr <number>`: `gh pr diff <number>` + `gh pr view <number> --json title,body,files`

### Step 1: Start Codex Session

Tell Codex to fetch the changes itself based on the scope. Include context if provided:

```bash
codex exec \
  --sandbox read-only \
  --full-auto \
  --skip-git-repo-check \
  "Review the code changes for scope: [SCOPE].

First, fetch the changes by running the appropriate git commands:
[GIT_COMMANDS_FOR_SCOPE]

[IF PLAN_FILE_PATH != 'none']
Read the plan file at: [PLAN_FILE_PATH]
This describes the intent of the changes. Consider this when reviewing.
[END IF]

[IF SUPPLEMENTARY_CONTEXT != 'none']
Additional context:
[SUPPLEMENTARY_CONTEXT]
[END IF]

Then review the changes. For each issue you find, provide:
1. What the issue is
2. Where it is (file and line if possible)
3. Why it matters
4. How to fix it

Consider:
- Code correctness and logic errors
- Security vulnerabilities
- Performance issues
- Code style and maintainability
- Missing error handling
- Test coverage gaps

Read any additional files you need for context.
When your review is complete, say 'REVIEW COMPLETE'." 2>/dev/null
```

### Step 2: Validate Feedback

For each piece of feedback from Codex:

1. **Is it specific?** If vague (e.g., "could be improved"), ask: "Can you be more specific about what should be improved and how?"

2. **Is it correct?** If Codex claims something about the code, verify by reading the relevant file yourself. If Codex is wrong, discard that feedback.

3. **Is it relevant?** Does the feedback apply to the actual changes, or is it about unrelated code? Discard tangential feedback.

4. **Is it actionable?** Could an AI agent implement the suggested fix? If not, ask Codex to clarify.

Resume the session to challenge questionable feedback:
```bash
echo "Regarding your point about [X]: Can you clarify [specific question]? I want to make sure this feedback is accurate before including it." | codex exec --skip-git-repo-check resume --last 2>/dev/null
```

### Step 3: Iterate Until Complete

Continue the validation loop until:
- All feedback has been validated or discarded
- Codex has no more issues to raise
- Max 5 iterations to prevent runaway

### Step 4: Synthesize Validated Feedback

Structure the validated feedback as follows:

```markdown
## Code Review Feedback

### Issue 1: [Descriptive Title]
**Severity:** critical | warning | suggestion
**Location:** `path/to/file.ts:42`
**Problem:** [Clear description of what the issue is]
**Why it matters:** [Why this is a problem - security, performance, correctness, etc.]
**Suggested fix:** [Concrete guidance on how to fix it - enough detail for an AI agent to implement]

### Issue 2: ...
[Repeat for each validated issue]

## Summary
- X critical issues requiring immediate attention
- Y warnings that should be addressed
- Z suggestions for improvement

**Recommendation:** needs-fixes | minor-cleanup | looks-good
```

### Important Notes

- Only include issues you have validated as legitimate
- Discard feedback that Codex couldn't justify when challenged
- If Codex finds no issues, that's a valid outcome - return "looks-good"
- Include enough detail in "Suggested fix" that another AI could implement it

---

## Step 5: Present Results

After the subagent returns, present the structured feedback to the user.

If issues were found, ask:
1. Would you like me to **address** any of these issues?
2. Would you like to **discuss** specific points?
3. Or **dismiss** the feedback and proceed as-is?
