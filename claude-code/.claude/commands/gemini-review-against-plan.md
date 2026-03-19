# Gemini Review Against Plan

Review code changes against an implementation plan using Google Gemini. Uses a subagent to iterate with Gemini and validate feedback before presenting results.

**Scopes:**
- `all` - Review all changes (untracked + unstaged + staged)
- `uncommitted` - Review untracked + unstaged only (ignore staged)
- `staged` - Review staged changes only (what would be committed)
- `branch [base]` - Review current branch vs base (default: master). Requires clean working directory.
- `pr <number>` - Review a specific PR
- `./path` or `/path` - Review files at specified path(s). Comma-separated for multiple.

**Flags:**
- `--no-context` - Skip supplementary context gathering
- `--model X` - Override the Gemini model (default: gemini-pro-latest)

**Usage:** `/gemini-review-against-plan [scope] [plan_path] [phase: N] [--flags]`

**Smart default:** If no scope given, detects feature branch → `branch`, otherwise → `all`

---

## Step 1: Parse Arguments

Parse `$ARGUMENTS` to extract scope, plan path, and flags:

```
$ARGUMENTS = "$ARGUMENTS"
```

**Parsing logic:**
1. Check for `--no-context` flag, remove from args
2. Check for `--model X` flag (X is the next token after --model), remove from args
3. Check for `phase: N` or `phase N` (N is a number) — extract as `[PHASE]`, remove from args
4. Identify plan file path (contains `/` or ends with `.md`)
5. Remaining text before plan path = scope

**Model determination:**
- If user specified `--model X`, use that as `[REQUESTED_MODEL]`
- Otherwise, default to `gemini-pro-latest` as `[REQUESTED_MODEL]`
- This ensures we always explicitly request the best available model

**Plan file detection:**
- If argument contains a plan file path → use that
- Else if you're in plan mode with a plan file path in context → use that path
- Else if plan content was injected into context (from "clear context and start working on the plan"):
  1. Look at the injected plan content in your conversation context. Find the **first `#` heading** — this is the plan's title (e.g., "# Plan: Implement Free Tier Pricing"). This is NOT the phase number, NOT any argument — it's the markdown heading from the plan document itself.
  2. Use the `mcp__plan-tools__find_plan_by_title` tool with that heading text (without the `#`) to find the matching file
  3. Tell the user: "Auto-detected plan: **[title]** (`[path]`). Proceeding."
  4. If no match found → fall back to `mcp__plan-tools__list_recent_plans` and pick the most recent
- Else → use `mcp__plan-tools__list_recent_plans` to show the 5 most recent plans, then ask the user which one
- **IMPORTANT:** Do NOT use Bash commands (ls, head, cat, grep), Glob, or Grep for plan file detection — these trigger security prompts. Use only the `plan-tools` MCP server tools.

**Scope detection (from remaining args):**
1. If starts with `all` → scope = all
2. If starts with `uncommitted` → scope = uncommitted
3. If starts with `staged` → scope = staged
4. If starts with `branch` → scope = branch, parse optional base (default: master)
5. If starts with `pr` → scope = pr, parse PR number (required)
6. If path-like (`./` or `/`) and NOT the plan file → scope = path
7. If empty → smart default:
   - Run `git branch --show-current`
   - If not `master` or `main` → scope = branch (base = master)
   - Else → scope = all

## Step 2: Validate Scope (Minimal)

**IMPORTANT: Do NOT fetch diffs. That pollutes your context.**

### For scope = `branch`
```bash
git status --porcelain
```
If non-empty, ABORT with:
> "Working directory has uncommitted changes. Please commit or stash first, or use `all`/`uncommitted` scope."

### For scope = `path`
Parse comma-separated paths, trim whitespace. Store as `[PATHS]`.

### All other scopes
No validation needed.

## Step 3: Gather Context (unless --no-context)

**Skip if `--no-context` flag provided.**

Gather supplementary context (do NOT read diffs or plan content!):

1. **Plan file path**: Already parsed. Store as `[PLAN_FILE_PATH]`.

2. **Supplementary context**: From conversation, extract info NOT in the plan:
   - Specific user concerns mentioned
   - Design decisions discussed verbally
   - Areas of uncertainty
   - Constraints not documented

Store as `[SUPPLEMENTARY_CONTEXT]` or "none".

## Step 4: Spawn Subagent

Use the Task tool to spawn a subagent. **Pass metadata only, not diffs or plan content.**

Fill placeholders and pass this prompt VERBATIM:

---

You are a plan-based code review assistant. Your job is to get feedback on code changes from Google Gemini, **validate** that feedback against the actual code, then return actionable results.

### CRITICAL RULES

0. **NO CD, NO GIT -C** - You are already in the correct working directory. Do NOT `cd`, do NOT use `git -C /path`. Just run commands directly. The ONLY Bash commands you should run are the `gemini` commands shown below - nothing else.
1. **READ-ONLY** - This is a review only. You may read files to verify but make NO changes.
2. **VALIDATE FEEDBACK** - Don't relay blindly. Challenge vague or questionable points.
3. **ITERATE** - Keep conversing with Gemini until review is complete and validated.
4. **ACTIONABLE OUTPUT** - Return structured feedback that could become a fix plan.
5. **GEMINI FETCHES DATA** - Gemini runs git commands itself. Do NOT fetch diffs yourself.

### Scope & Context

**Scope:** [SCOPE]
**Base (if branch):** [BASE]
**Paths (if path):** [PATHS]

**Plan file path:** [PLAN_FILE_PATH]
**Phase:** [PHASE or "all"]
Gemini MUST read this file to understand the intended implementation. If a specific phase is given, focus the review on that phase's items (but read the full plan for context).

**Supplementary context:** [SUPPLEMENTARY_CONTEXT]

**How Gemini should fetch changes based on scope (use git-tools MCP if available, fall back to git commands):**
- `all`: `mcp__git-tools__git_diff` with `scope: "all"` (or `git diff` + `git diff --cached` + `git ls-files --others --exclude-standard`)
- `uncommitted`: `mcp__git-tools__git_diff` with `scope: "unstaged"` (or `git diff` + `git ls-files --others --exclude-standard`)
- `staged`: `mcp__git-tools__git_diff` with `scope: "staged"` (or `git diff --cached`)
- `branch [base]`: `mcp__git-tools__git_diff` with `scope: "branch"`, `base: "[base]"` (or `git diff [base]...HEAD` + `git log [base]...HEAD --oneline`)
- `pr <number>`: `gh pr diff <number>` + `gh pr view <number> --json title,body,files`
- `path`: No git commands. Read and explore the paths directly.

### Step 1: Start Gemini Session

```bash
gemini -m [REQUESTED_MODEL] "Review code changes against an implementation plan.

STEP 1: Fetch the code changes
Run these git commands based on scope '[SCOPE]':
[GIT_COMMANDS_FOR_SCOPE]

STEP 2: Read the plan file
Use the plan-tools MCP read_plan tool to read: [PLAN_FILE_PATH]
(If the MCP tool is unavailable, read the file directly.)
This describes what SHOULD be implemented.

[IF PHASE != 'all']
IMPORTANT: Focus your review on **Phase [PHASE]** of the plan only. Read the full plan for context but only check items from Phase [PHASE].
[END IF]

[IF SUPPLEMENTARY_CONTEXT != 'none']
STEP 3: Consider this additional context:
[SUPPLEMENTARY_CONTEXT]
[END IF]

STEP 4: Review the changes AGAINST the plan

For EACH item in the plan [IF PHASE != 'all'](Phase [PHASE] only)[END IF], check:
- Is it implemented? (complete/partial/missing)
- Does the implementation match the plan's intent?
- Is the code quality acceptable?

Also check for:
- Code that doesn't relate to any plan item (scope creep)
- Debug artifacts (console.log, debugger, TODO comments)
- Code quality issues (deep nesting, poor naming, missing error handling)
- Coding standard violations
- Files in wrong locations

For each issue found, provide:
1. What plan item it relates to (or 'out-of-scope')
2. What the issue is
3. Where (file:line if possible)
4. Why it matters
5. How to fix it

Read additional files as needed for context.

Before your review, state: 'MODEL_ID: [your model name/version]'
When done, say 'REVIEW COMPLETE'."
```

**For scope = path, use this prompt instead:**

```bash
gemini -m [REQUESTED_MODEL] "Review code at specific paths against an implementation plan.

STEP 1: Read the plan file
Use the plan-tools MCP read_plan tool to read: [PLAN_FILE_PATH]
(If the MCP tool is unavailable, read the file directly.)
This describes what SHOULD be implemented.

[IF PHASE != 'all']
IMPORTANT: Focus your review on **Phase [PHASE]** of the plan only. Read the full plan for context but only check items from Phase [PHASE].
[END IF]

STEP 2: Explore the code paths
Paths to review: [PATHS]
For each path:
- If directory: explore structure and review key files
- If file: read and review contents
- Follow imports as needed

[IF SUPPLEMENTARY_CONTEXT != 'none']
STEP 3: Consider this additional context:
[SUPPLEMENTARY_CONTEXT]
[END IF]

STEP 4: Review the code AGAINST the plan

For EACH item in the plan [IF PHASE != 'all'](Phase [PHASE] only)[END IF], check:
- Is it implemented in these files?
- Does the implementation match the plan's intent?
- Is the code quality acceptable?

Also check for:
- Code that doesn't relate to any plan item
- Debug artifacts, TODO comments
- Code quality issues
- Coding standard violations

For each issue found, provide:
1. What plan item it relates to
2. What the issue is
3. Where (file:line)
4. Why it matters
5. How to fix it

Before your review, state: 'MODEL_ID: [your model name/version]'
When done, say 'REVIEW COMPLETE'."
```

### Step 1b: Capture Model Info

After receiving Gemini's initial response:
- Look for a `MODEL_ID: ...` line in the output
- Store the reported model as `[CONFIRMED_MODEL]`
- If no MODEL_ID line found, set `[CONFIRMED_MODEL]` to "unknown (not reported)"

### Step 2: Validate Feedback

For each piece of feedback from Gemini:

1. **Is it specific?** If vague (e.g., "could be improved"), ask: "What specifically should be improved and how?"

2. **Is it correct?** If Gemini claims something about the code, read the file yourself to verify. Discard incorrect feedback.

3. **Is it relevant?** Does it relate to the actual changes and plan? Discard tangential feedback.

4. **Is it actionable?** Could an AI agent implement the fix? If not, ask for clarification.

Resume session to challenge questionable feedback:
```bash
gemini --resume latest "Regarding [X]: Can you clarify [specific question]? I need to verify this before including it."
```

### Step 3: Iterate Until Complete

Continue until:
- All feedback validated or discarded
- Gemini has no more issues
- Max 5 iterations to prevent runaway

### Step 4: Synthesize Output

Structure ALL validated feedback:

```markdown
## Review Against Plan: [Plan Title/Path]

### Plan Coverage
| Plan Item | Status | Issue | Location |
|-----------|--------|-------|----------|
| [Item from plan] | Complete | - | - |
| [Item from plan] | Partial | [Specific gap] | `file:line` |
| [Item from plan] | Missing | Not implemented | - |

### Code Quality Issues

#### Issue 1: [Descriptive Title]
**Severity:** critical | warning | suggestion
**Plan Item:** [Related plan item or "N/A - general quality"]
**Location:** `path/to/file.ts:42`
**Problem:** [Clear description]
**Why it matters:** [Impact on correctness, security, maintainability]
**Suggested fix:** [Concrete steps - enough for AI to implement]

#### Issue 2: ...

### Out-of-Scope Changes
(Only if unexpected changes found)
- `[file]` - [What it does, why it's not in plan]

## Summary
- Plan items: X complete, Y partial, Z missing out of N total
- Quality issues: X critical, Y warnings, Z suggestions

**Recommendation:** ready-to-commit | needs-fixes | needs-discussion

## Models Used
- **Gemini requested:** [REQUESTED_MODEL]
- **Gemini confirmed:** [CONFIRMED_MODEL]
- **Claude subagent:** [self-report your model name/version]
```

**If all plan items complete and no issues:**
```markdown
## Review Against Plan: [Plan Title/Path]

All plan items implemented. No quality issues found.

- Plan items: X/X complete
- Quality issues: None

**Recommendation:** ready-to-commit

## Models Used
- **Gemini requested:** [REQUESTED_MODEL]
- **Gemini confirmed:** [CONFIRMED_MODEL]
- **Claude subagent:** [self-report your model name/version]
```

### Important Notes

- Only include validated feedback
- Discard anything Gemini couldn't justify
- Include enough detail in "Suggested fix" for another AI to act on it
- If Gemini hits quota errors or the requested model is unavailable:
  1. Retry with `-m gemini-2.5-flash`
  2. Note in Models Used: "gemini-2.5-flash (fallback from [REQUESTED_MODEL] due to quota)"
  3. Still capture MODEL_ID from Gemini's response

---

## Step 5: Present Results

**CRITICAL: Output the subagent's feedback VERBATIM.** Do NOT summarize, condense, or reformat it. The subagent produces detailed structured output with per-issue descriptions, locations, and suggested fixes — the user needs ALL of that detail to make informed decisions. Do NOT compress issues into a summary table with one-line descriptions.

If the subagent's output is missing or empty, say so. Otherwise, paste it through exactly as returned.

**Always include the "Models Used" section** so the user can see what models were used. If the Gemini confirmed model differs from what was requested, highlight this discrepancy.

**Save findings for triage:** After outputting the review verbatim, save the complete output using `mcp__plan-tools__write_plan`.

**File naming:**
1. **If a plan file is in context** (e.g., `~/.claude/plans/proud-skipping-wirth.md`):
   - Extract the plan slug (filename without `.md`)
   - Write to `~/.claude/plans/{plan-slug}-code-review-round-1.md`
   - If `round-1` already exists, use `round-2`, `round-3`, etc.
   - Use `mcp__plan-tools__find_plan_by_title` to check for existing rounds
2. **If no plan file in context**:
   - Create: `~/.claude/plans/code-review-{generated-slug}.md`

**Prepend YAML frontmatter** with: `title` ("Code Review - {plan title or 'Standalone'} - Round N"), `date` (current ISO date), `review_type` ("code-review"), `scope` (the scope used), and `source_plan` (path to original plan file, or "none").

This enables the `/triage-review` command to process findings interactively.

After presenting the full output, ask:
1. Would you like me to **address** specific issues (or run `/triage-review` to go through them one-by-one)?
2. Would you like to **discuss** any points?
3. Or **dismiss** the feedback and proceed?
