# Claude Code Review

Get a comprehensive code review using parallel specialized review agents. An orchestrator coordinates focused reviewers (correctness, security, quality), validates their findings against actual source code, and returns only high-confidence, actionable feedback.

**Scopes:**
- `all` - Review all changes (untracked + unstaged + staged)
- `uncommitted` - Review untracked + unstaged only (ignore staged)
- `staged` - Review staged changes only (what would be committed)
- `branch [base]` - Review current branch vs base (default: master). Requires clean working directory.
- `pr <number>` - Review a specific PR
- `./path` or `/path` - Review files at specified path(s). Use `./` for relative paths, `/` for absolute. Comma-separated for multiple.

**Flags:**
- `--no-context` - Skip context gathering for a "blind" review
- `--model X` - Override the Claude model (default: opus)

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
- Remove flags from arguments before parsing scope

**Model determination:**
- If user specified `--model X`, use that as `[REQUESTED_MODEL]`
- Otherwise, default to `opus` as `[REQUESTED_MODEL]`
- Valid models: `opus`, `sonnet`, `haiku`, or full model IDs like `claude-opus-4-6`

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

Gather context to help Claude understand the INTENT of changes (do NOT fetch diffs!):

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

## Step 4: Spawn Review Orchestrator

Use the Agent tool to spawn a `review-orchestrator` agent (subagent_type: `review-orchestrator`, model: `sonnet`). **Do NOT pass any diff content or file contents** — only pass structured metadata. The orchestrator and its sub-agents will fetch everything themselves.

Pass the following prompt, filling in all placeholders with values from Steps 1-3:

```
REVIEW_MODE: code-review
SCOPE: [SCOPE]
BASE: [BASE or "N/A"]
PATHS: [PATHS or "N/A"]
PR: [PR_NUMBER or "N/A"]
PLAN_FILE: [PLAN_FILE_PATH]
SUPPLEMENTARY_CONTEXT: [SUPPLEMENTARY_CONTEXT]
REVIEWER_MODEL: [REQUESTED_MODEL]
```

The orchestrator will:
1. Fetch the diff itself based on the scope
2. Spawn parallel `code-reviewer` agents (correctness, security, quality) using the specified model
3. Validate all findings against actual source code
4. Filter false positives and deduplicate
5. Return structured feedback

## Step 5: Present Results

After the orchestrator returns, present its structured feedback to the user.

If issues were found, ask:
1. Would you like me to **address** any of these issues?
2. Would you like to **discuss** specific points?
3. Or **dismiss** the feedback and proceed as-is?
