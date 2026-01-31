# Codex Review Against Plan

Review code changes against an implementation plan using OpenAI Codex. Uses a subagent to iterate with Codex and validate feedback before presenting results.

**Scopes:**
- `all` - Review all changes (untracked + unstaged + staged)
- `uncommitted` - Review untracked + unstaged only (ignore staged)
- `staged` - Review staged changes only (what would be committed)
- `branch [base]` - Review current branch vs base (default: master). Requires clean working directory.
- `pr <number>` - Review a specific PR
- `./path` or `/path` - Review files at specified path(s). Comma-separated for multiple.

**Flags:**
- `--no-context` - Skip supplementary context gathering

**Usage:** `/codex-review-against-plan [scope] <plan_path> [--flags]`

**Smart default:** If no scope given, detects feature branch → `branch`, otherwise → `all`

---

## Step 1: Parse Arguments

Parse `$ARGUMENTS` to extract scope, plan path, and flags:

```
$ARGUMENTS = "$ARGUMENTS"
```

**Parsing logic:**
1. Check for `--no-context` flag, remove from args
2. Identify plan file path (contains `/` or ends with `.md`)
3. Remaining text before plan path = scope

**Plan file detection:**
- If argument contains a path → use that
- Else check if you're in plan mode with a plan file in context
- If neither → ABORT: "Cannot review without a plan file. Usage: /codex-review-against-plan [scope] <plan_path>"

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

You are a plan-based code review assistant. Your job is to get feedback on code changes from OpenAI Codex, **validate** that feedback against the actual code, then return actionable results.

### CRITICAL RULES

1. **READ-ONLY** - Codex runs with `--sandbox read-only`. You may read files to verify but make NO changes.
2. **VALIDATE FEEDBACK** - Don't relay blindly. Challenge vague or questionable points.
3. **ITERATE** - Keep conversing with Codex until review is complete and validated.
4. **ACTIONABLE OUTPUT** - Return structured feedback that could become a fix plan.
5. **CODEX FETCHES DATA** - Codex runs git commands itself. Do NOT fetch diffs yourself.

### Scope & Context

**Scope:** [SCOPE]
**Base (if branch):** [BASE]
**Paths (if path):** [PATHS]

**Plan file path:** [PLAN_FILE_PATH]
Codex MUST read this file to understand the intended implementation.

**Supplementary context:** [SUPPLEMENTARY_CONTEXT]

**Git commands Codex should run based on scope:**
- `all`: `git diff` + `git diff --cached` + `git ls-files --others --exclude-standard`
- `uncommitted`: `git diff` + `git ls-files --others --exclude-standard`
- `staged`: `git diff --cached`
- `branch [base]`: `git diff [base]...HEAD` + `git log [base]...HEAD --oneline`
- `pr <number>`: `gh pr diff <number>` + `gh pr view <number> --json title,body,files`
- `path`: No git commands. Read and explore the paths directly.

### Step 1: Start Codex Session

```bash
codex exec \
  --sandbox read-only \
  --full-auto \
  --skip-git-repo-check \
  "Review code changes against an implementation plan.

STEP 1: Fetch the code changes
Run these git commands based on scope '[SCOPE]':
[GIT_COMMANDS_FOR_SCOPE]

STEP 2: Read the plan file
Read: [PLAN_FILE_PATH]
This describes what SHOULD be implemented.

[IF SUPPLEMENTARY_CONTEXT != 'none']
STEP 3: Consider this additional context:
[SUPPLEMENTARY_CONTEXT]
[END IF]

STEP 4: Review the changes AGAINST the plan

For EACH item in the plan, check:
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
When done, say 'REVIEW COMPLETE'." 2>/dev/null
```

**For scope = path, use this prompt instead:**

```bash
codex exec \
  --sandbox read-only \
  --full-auto \
  --skip-git-repo-check \
  "Review code at specific paths against an implementation plan.

STEP 1: Read the plan file
Read: [PLAN_FILE_PATH]
This describes what SHOULD be implemented.

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

For EACH item in the plan, check:
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

When done, say 'REVIEW COMPLETE'." 2>/dev/null
```

### Step 2: Validate Feedback

For each piece of feedback from Codex:

1. **Is it specific?** If vague (e.g., "could be improved"), ask: "What specifically should be improved and how?"

2. **Is it correct?** If Codex claims something about the code, read the file yourself to verify. Discard incorrect feedback.

3. **Is it relevant?** Does it relate to the actual changes and plan? Discard tangential feedback.

4. **Is it actionable?** Could an AI agent implement the fix? If not, ask for clarification.

Resume session to challenge questionable feedback:
```bash
echo "Regarding [X]: Can you clarify [specific question]? I need to verify this before including it." | codex exec --skip-git-repo-check resume --last 2>/dev/null
```

### Step 3: Iterate Until Complete

Continue until:
- All feedback validated or discarded
- Codex has no more issues
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
```

**If all plan items complete and no issues:**
```markdown
## Review Against Plan: [Plan Title/Path]

All plan items implemented. No quality issues found.

- Plan items: X/X complete
- Quality issues: None

**Recommendation:** ready-to-commit
```

### Important Notes

- Only include validated feedback
- Discard anything Codex couldn't justify
- Include enough detail in "Suggested fix" for another AI to act on it
- If Codex encounters errors, report them and ask for guidance

---

## Step 5: Present Results

After subagent returns, present the structured feedback.

If issues were found, ask:
1. Would you like me to **address** specific issues?
2. Would you like to **discuss** any points?
3. Or **dismiss** the feedback and proceed?
