# Claude Review Against Plan

Review code changes against an implementation plan using parallel specialized review agents. Spawns focused reviewers (correctness, security, quality, plan-compliance) in parallel, then a merger validates findings and returns a plan coverage table alongside code quality issues.

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

## Step 4: Create Review Session and Spawn Code Reviewers (Parallel)

**First**, call `mcp__review-tools__create_review_session` to create a temp directory for this review. If a plan file path is available, pass its basename (without `.md`) as the `slug`. Store the returned path as `[SESSION_DIR]`.

**Then**, spawn **4** `code-reviewer` agents in parallel using the Agent tool. All 4 Agent calls MUST be in the **same message** for true parallelism. Each agent gets `subagent_type: "code-reviewer"` and `model: [REQUESTED_MODEL]`.

**Do NOT pass any diff content, file contents, or plan content** — only pass structured metadata. Each reviewer fetches diffs and reads source files independently. Each reviewer writes findings to the session directory via MCP and returns only a brief summary.

Spawn these 4 agents with these prompts (filling in placeholders from Steps 1-3):

**Agent 1 — Correctness:**
```
FOCUS: correctness
SCOPE: [SCOPE]
BASE: [BASE or "N/A"]
PATHS: [PATHS or "N/A"]
PR: [PR_NUMBER or "N/A"]
SUPPLEMENTARY_CONTEXT: [SUPPLEMENTARY_CONTEXT]
REVIEWER_MODEL: [REQUESTED_MODEL]
SESSION_DIR: [SESSION_DIR]
```

**Agent 2 — Security:**
```
FOCUS: security
SCOPE: [SCOPE]
BASE: [BASE or "N/A"]
PATHS: [PATHS or "N/A"]
PR: [PR_NUMBER or "N/A"]
SUPPLEMENTARY_CONTEXT: [SUPPLEMENTARY_CONTEXT]
REVIEWER_MODEL: [REQUESTED_MODEL]
SESSION_DIR: [SESSION_DIR]
```

**Agent 3 — Quality:**
```
FOCUS: quality
SCOPE: [SCOPE]
BASE: [BASE or "N/A"]
PATHS: [PATHS or "N/A"]
PR: [PR_NUMBER or "N/A"]
SUPPLEMENTARY_CONTEXT: [SUPPLEMENTARY_CONTEXT]
REVIEWER_MODEL: [REQUESTED_MODEL]
SESSION_DIR: [SESSION_DIR]
```

**Agent 4 — Plan Compliance:**
```
FOCUS: plan-compliance
SCOPE: [SCOPE]
BASE: [BASE or "N/A"]
PATHS: [PATHS or "N/A"]
PR: [PR_NUMBER or "N/A"]
PLAN_FILE: [PLAN_FILE_PATH]
PHASE: [PHASE or "all"]
SUPPLEMENTARY_CONTEXT: [SUPPLEMENTARY_CONTEXT]
REVIEWER_MODEL: [REQUESTED_MODEL]
SESSION_DIR: [SESSION_DIR]
```

## Step 5: Spawn Review Merger

After all 4 code-reviewer agents return, spawn 1 `review-merger` agent (subagent_type: `review-merger`, model: `sonnet`).

Pass only scope metadata and the session directory — the merger reads findings from temp files via MCP:

```
REVIEW_MODE: review-against-plan
SCOPE: [SCOPE]
BASE: [BASE or "N/A"]
PATHS: [PATHS or "N/A"]
PR: [PR_NUMBER or "N/A"]
PLAN_FILE: [PLAN_FILE_PATH]
PHASE: [PHASE or "all"]
REVIEWER_MODEL: [REQUESTED_MODEL]
FOCUS_AREAS: correctness, security, quality, plan-compliance
SESSION_DIR: [SESSION_DIR]
```

The merger will:
1. Load findings from the session directory via `mcp__review-tools__read_all_findings`
2. Fetch the diff independently for validation
3. Re-read source files to verify each finding
4. Read the plan file to produce the coverage table
5. Filter false positives, deduplicate across reviewers
6. Produce final structured feedback with plan coverage table

## Step 6: Present Results

**CRITICAL: Output the merger's feedback VERBATIM.** Do NOT summarize, condense, or reformat it. The merger produces detailed structured output with per-issue descriptions, locations, and suggested fixes — the user needs ALL of that detail to make informed decisions. Do NOT compress issues into a summary table with one-line descriptions.

If the merger's output is missing or empty, say so. Otherwise, paste it through exactly as returned.

After presenting the full output, ask:
1. Would you like me to **address** specific issues?
2. Would you like to **discuss** any points?
3. Or **dismiss** the feedback and proceed?
