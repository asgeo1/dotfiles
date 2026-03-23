# Codex Code Review

Get a comprehensive code review from OpenAI Codex with validated, refined feedback. Uses a subagent to iterate with Codex and filter out invalid suggestions before presenting to you.

**Scopes:**
- `all` - Review all changes (untracked + unstaged + staged)
- `uncommitted` - Review untracked + unstaged only (ignore staged)
- `staged` - Review staged changes only (what would be committed)
- `branch [base]` - Review current branch vs base (default: master). Requires clean working directory.
- `pr <number>` - Review a specific PR
- `./path` or `/path` - Review files at specified path(s). Use `./` for relative paths, `/` for absolute. Comma-separated for multiple.

**Flags:**
- `--no-context` - Skip context gathering for a "blind" review
- `--model X` - Override the Codex model (default: Codex CLI's default)
- `--reasoning X` - Set reasoning effort (xhigh|high|medium|low)

**Smart default:** If no scope given, detects feature branch → `branch`, otherwise → `all`

---

## Step 1: Parse Scope and Flags from Arguments

Parse `$ARGUMENTS` to determine scope and flags:

```
$ARGUMENTS = "$ARGUMENTS"
```

**Flag detection:**
- Check for `--no-context` flag anywhere in arguments
- Check for `--model X` flag (X is the next token after --model)
- Check for `--reasoning X` flag
- Remove flags from arguments before parsing scope

**Model determination:**
- If user specified `--model X`, store as `[REQUESTED_MODEL]` and set `[MODEL_FLAG]` to `--model X`
- Otherwise, `[REQUESTED_MODEL]` = "default" and `[MODEL_FLAG]` = "" (empty, use Codex CLI's default)
- If user specified `--reasoning X`, store as `[REASONING_OVERRIDE]` → `--config model_reasoning_effort="X"`

**Scope detection logic:**
1. If starts with `all` → scope = all
2. If starts with `uncommitted` → scope = uncommitted
3. If starts with `staged` → scope = staged
4. If starts with `branch` → scope = branch, parse optional base (default: master)
5. If starts with `pr` → scope = pr, parse PR number (required)
6. If starts with `./` or `/` → scope = path, store path string
7. If empty → smart default:
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

### For scope = `path`
Parse the comma-separated paths into a list (trim whitespace from each path). No filesystem validation needed - the AI will explore and report.
Store as `[PATHS]` for the subagent.

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

0. **NO CD, NO GIT -C** - You are already in the correct working directory. Do NOT `cd`, do NOT use `git -C /path`. Just run commands directly. The ONLY Bash commands you should run are the `codex exec` commands shown below - nothing else.
1. **READ-ONLY** - Codex runs with `--sandbox read-only`. You may read files to verify claims but make NO changes.
2. **VALIDATE FEEDBACK** - Don't just relay Codex's feedback. Challenge vague or questionable points.
3. **ITERATE** - Keep conversing with Codex until feedback is complete and validated.
4. **ACTIONABLE OUTPUT** - Return structured feedback that an AI agent could act on.
5. **CODEX FETCHES CONTEXT** - Codex will run git commands itself to get the diff. Do NOT fetch diffs yourself.

### Scope

**Scope:** [SCOPE]
**Base (if branch scope):** [BASE]
**Paths (if path scope):** [PATHS]

### Context

**Plan file path:** [PLAN_FILE_PATH]
If a path is provided, you and Codex can read this file to understand the intent of the changes. Don't just blindly accept feedback that contradicts the plan.

**Supplementary context:** [SUPPLEMENTARY_CONTEXT]
This is additional relevant information from the main conversation that isn't in the plan file.

**How Codex should fetch changes based on scope (use git-tools MCP if available, fall back to git commands):**
- `all`: `mcp__git-tools__git_diff` with `scope: "all"` (or `git diff` + `git diff --cached` + `git ls-files --others --exclude-standard`)
- `uncommitted`: `mcp__git-tools__git_diff` with `scope: "unstaged"` (or `git diff` + `git ls-files --others --exclude-standard`)
- `staged`: `mcp__git-tools__git_diff` with `scope: "staged"` (or `git diff --cached`)
- `branch [base]`: `mcp__git-tools__git_diff` with `scope: "branch"`, `base: "[base]"` (or `git diff [base]...HEAD` + `git log [base]...HEAD --oneline`)
- `pr <number>`: `gh pr diff <number>` + `gh pr view <number> --json title,body,files`
- `path`: No git commands. Read and explore the paths directly.

### Step 1: Start Codex Session

Tell Codex to fetch the changes itself based on the scope. Include context if provided:

```bash
codex exec \
  --sandbox read-only \
  --full-auto \
  --skip-git-repo-check \
  [MODEL_FLAG] \
  [REASONING_OVERRIDE] \
  "Review the code changes for scope: [SCOPE].

First, fetch the changes by running the appropriate git commands:
[GIT_COMMANDS_FOR_SCOPE]

[IF PLAN_FILE_PATH != 'none']
Use the plan-tools MCP read_plan tool to read the plan file at: [PLAN_FILE_PATH]
(If the MCP tool is unavailable, read the file directly.)
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

Before your review, state: 'MODEL_ID: [your model name/version]'
When your review is complete, say 'REVIEW COMPLETE'." 2>/dev/null
```

**For scope = path, use this prompt instead:**

```bash
codex exec \
  --sandbox read-only \
  --full-auto \
  --skip-git-repo-check \
  [MODEL_FLAG] \
  [REASONING_OVERRIDE] \
  "Review the code at the following path(s): [PATHS]

For each path:
- If it's a directory, explore its structure and review key files
- If it's a file, read and review its contents
- Follow imports and references as needed for context

[IF PLAN_FILE_PATH != 'none']
Use the plan-tools MCP read_plan tool to read the plan file at: [PLAN_FILE_PATH]
(If the MCP tool is unavailable, read the file directly.)
This describes the intent of the changes. Consider this when reviewing.
[END IF]

[IF SUPPLEMENTARY_CONTEXT != 'none']
Additional context:
[SUPPLEMENTARY_CONTEXT]
[END IF]

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

Before your review, state: 'MODEL_ID: [your model name/version]'
When your review is complete, say 'REVIEW COMPLETE'." 2>/dev/null
```

### Step 1b: Capture Model Info

After receiving Codex's initial response:
- Look for a `MODEL_ID: ...` line in the output
- Store the reported model as `[CONFIRMED_MODEL]`
- If no MODEL_ID line found, set `[CONFIRMED_MODEL]` to "unknown (not reported)"

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
**Focus:** correctness | security | quality | plan-compliance
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

## Models Used
- **Codex requested:** [REQUESTED_MODEL]
- **Codex confirmed:** [CONFIRMED_MODEL]
- **Claude subagent:** [self-report your model name/version]
```

### Important Notes

- Only include issues you have validated as legitimate
- Discard feedback that Codex couldn't justify when challenged
- If Codex finds no issues, that's a valid outcome - return "looks-good"
- Include enough detail in "Suggested fix" that another AI could implement it
- If Codex encounters model errors or the requested model is unavailable:
  1. Retry without --model flag (use CLI default)
  2. Note in Models Used: "default (fallback from [REQUESTED_MODEL])"
  3. Still capture MODEL_ID from Codex's response

---

## Step 5: Present Results

**CRITICAL: Output the subagent's feedback VERBATIM.** Do NOT summarize, condense, or reformat it. The subagent produces detailed structured output with per-issue descriptions, locations, and suggested fixes — the user needs ALL of that detail to make informed decisions. Do NOT compress issues into a summary table with one-line descriptions.

If the subagent's output is missing or empty, say so. Otherwise, paste it through exactly as returned.

**Always include the "Models Used" section** so the user can see what models were used. If the Codex confirmed model differs from what was requested, highlight this discrepancy.

**Save findings for triage:** After outputting the review verbatim, save the complete output using `mcp__plan-tools__write_plan`.

**File naming:**
1. **If a plan file is in context** (e.g., `~/.claude/plans/proud-skipping-wirth.md`):
   - Extract the plan slug (filename without `.md`)
   - Write to `~/.claude/plans/{plan-slug}-code-review-round-1.md`
   - If `round-1` already exists, use `round-2`, `round-3`, etc.
   - Use `mcp__plan-tools__find_plan_by_title` to check for existing rounds
2. **If no plan file in context** (e.g., standalone code review):
   - Create: `~/.claude/plans/code-review-{generated-slug}.md`

**Prepend YAML frontmatter** with: `title` ("Code Review - {plan title or 'Standalone'} - Round N"), `date` (current ISO date), `review_type` ("code-review"), `scope` (the scope used), and `source_plan` (path to original plan file, or "none").

This enables the `/triage-review` command to process findings interactively.

After presenting the full output, ask:
1. Would you like me to **address** specific issues (or run `/triage-review` to go through them one-by-one)?
2. Would you like to **discuss** any points?
3. Or **dismiss** the feedback and proceed?
