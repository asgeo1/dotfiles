# Claude Review Against Plan

Review code changes against an implementation plan using parallel specialized review agents. An orchestrator coordinates focused reviewers (correctness, security, quality, plan-compliance), validates findings, and returns a plan coverage table alongside code quality issues.

**Scopes:**
- `all` - Review all changes (untracked + unstaged + staged)
- `uncommitted` - Review untracked + unstaged only (ignore staged)
- `staged` - Review staged changes only (what would be committed)
- `branch [base]` - Review current branch vs base (default: master). Requires clean working directory.
- `pr <number>` - Review a specific PR
- `./path` or `/path` - Review files at specified path(s). Comma-separated for multiple.

**Flags:**
- `--no-context` - Skip supplementary context gathering
- `--model X` - Override the Claude model (default: opus)

**Usage:** `/claude-review-against-plan [scope] [plan_path] [phase: N] [--flags]`

**Smart default:** If no scope given, detects feature branch → `branch`, otherwise → `all`

---

## Step 1: Parse Arguments

Parse `$ARGUMENTS` to extract scope, plan path, phase, and flags:

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
- Otherwise, default to `opus` as `[REQUESTED_MODEL]`
- Valid models: `opus`, `sonnet`, `haiku`, or full model IDs

**Plan file detection:**
- If argument contains a plan file path → use that
- Else if you're in plan mode with a plan file path in context → use that path
- Else if plan content was injected into context (from "clear context and start working on the plan"):
  1. Look at the injected plan content in your conversation context. Find the **first `#` heading** — this is the plan's title (e.g., "# Plan: Implement Free Tier Pricing"). This is NOT the phase number, NOT the scope, NOT any argument — it's the markdown heading from the plan document itself.
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

## Step 4: Spawn Review Orchestrator

Use the Agent tool to spawn a `review-orchestrator` agent (subagent_type: `review-orchestrator`, model: `sonnet`). **Do NOT pass any diff content, file contents, or plan content** — only pass structured metadata. The orchestrator and its sub-agents will fetch everything themselves.

Pass the following prompt, filling in all placeholders with values from Steps 1-3:

```
REVIEW_MODE: review-against-plan
SCOPE: [SCOPE]
BASE: [BASE or "N/A"]
PATHS: [PATHS or "N/A"]
PR: [PR_NUMBER or "N/A"]
PLAN_FILE: [PLAN_FILE_PATH]
PHASE: [PHASE or "all"]
SUPPLEMENTARY_CONTEXT: [SUPPLEMENTARY_CONTEXT]
REVIEWER_MODEL: [REQUESTED_MODEL]
```

The orchestrator will:
1. Fetch the diff itself based on the scope
2. Spawn parallel `code-reviewer` agents (correctness, security, quality, **plan-compliance**) using the specified model
3. The plan-compliance reviewer will read the plan file and review against the specified phase (or the entire plan if "all")
4. Validate all findings against actual source code
5. Filter false positives and deduplicate
6. Return structured feedback with plan coverage table

## Step 5: Present Results

After the orchestrator returns, present its structured feedback to the user.

If issues were found, ask:
1. Would you like me to **address** specific issues?
2. Would you like to **discuss** any points?
3. Or **dismiss** the feedback and proceed?
