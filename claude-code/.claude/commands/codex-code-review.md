# Codex Code Review

Get a comprehensive code review from OpenAI Codex with validated, refined feedback. Uses a subagent to iterate with Codex and filter out invalid suggestions before presenting to you.

**Scopes:**
- `all` - Review all changes (untracked + unstaged + staged)
- `uncommitted` - Review untracked + unstaged only (ignore staged)
- `staged` - Review staged changes only (what would be committed)
- `branch [base]` - Review current branch vs base (default: master). Requires clean working directory.
- `pr <number>` - Review a specific PR

**Smart default:** If no scope given, detects feature branch → `branch`, otherwise → `all`

---

## Step 1: Parse Scope from Arguments

Parse `$ARGUMENTS` to determine scope:

```
$ARGUMENTS = "$ARGUMENTS"
```

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

## Step 2: Validate and Gather Changes

### For scope = `branch`
First, check for dirty working directory:
```bash
git status --porcelain
```
If output is non-empty, ABORT with:
> "Working directory has uncommitted changes. Please commit or stash first, or use `all`/`uncommitted` scope to review working directory changes."

Then gather branch diff:
```bash
git diff <base>...HEAD
git log <base>...HEAD --oneline
```

### For scope = `all`
```bash
git status --short
git diff                    # unstaged changes
git diff --cached           # staged changes
git ls-files --others --exclude-standard  # untracked files
```

### For scope = `uncommitted`
```bash
git status --short
git diff                    # unstaged changes only
git ls-files --others --exclude-standard  # untracked files
```

### For scope = `staged`
```bash
git diff --cached           # staged changes only
git diff --cached --stat    # summary of staged files
```

### For scope = `pr`
```bash
gh pr view <number> --json title,body,author,baseRefName,headRefName,files,additions,deletions
gh pr diff <number>
```

## Step 3: Spawn Subagent

Use the Task tool to spawn a subagent. Pass the following prompt VERBATIM (fill in the placeholders):

---

You are a code review assistant. Your job is to get feedback on code changes from OpenAI Codex, **validate and refine** that feedback, then return actionable results.

### CRITICAL RULES

1. **READ-ONLY** - Codex runs with `--sandbox read-only`. You may read files to verify claims but make NO changes.
2. **VALIDATE FEEDBACK** - Don't just relay Codex's feedback. Challenge vague or questionable points.
3. **ITERATE** - Keep conversing with Codex until feedback is complete and validated.
4. **ACTIONABLE OUTPUT** - Return structured feedback that an AI agent could act on.

### Context

**Scope:** [SCOPE]
**What's being reviewed:** [SCOPE_DESCRIPTION]

**Changes to review:**
```
[DIFF_CONTENT]
```

**Changed files:**
[FILE_LIST]

### Step 1: Start Codex Session

```bash
codex exec \
  --sandbox read-only \
  --full-auto \
  --skip-git-repo-check \
  "Review the following code changes. Analyze them in the context of this codebase.

Changes:
[DIFF_CONTENT]

For each issue you find, provide:
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

## Step 4: Present Results

After the subagent returns, present the structured feedback to the user.

If issues were found, ask:
1. Would you like me to **address** any of these issues?
2. Would you like to **discuss** specific points?
3. Or **dismiss** the feedback and proceed as-is?
