---
name: claude-code-review
description: Use when the user asks for a code review using Claude with parallel review agents, or invokes /claude-code-review
user-invocable: true
---

# Claude Code Review

Get a comprehensive code review using parallel specialized review agents. Spawns focused reviewers (correctness, security, quality) in parallel, then a merger validates their findings against actual source code and returns only high-confidence, actionable feedback.

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

## Step 4: Create Review Session and Spawn Code Reviewers (Parallel)

**First**, call `mcp__review-tools__create_review_session` to create a temp directory for this review. If a plan file path is available, pass its basename (without `.md`) as the `slug`. Store the returned path as `[SESSION_DIR]`.

**Then**, spawn **3** `code-reviewer` agents in parallel using the Agent tool. All 3 Agent calls MUST be in the **same message** for true parallelism. Each agent gets `subagent_type: "code-reviewer"` and `model: [REQUESTED_MODEL]`.

**Do NOT pass any diff content or file contents** — only pass structured metadata. Each reviewer fetches diffs and reads source files independently. Each reviewer writes findings to the session directory via MCP and returns only a brief summary.

Spawn these 3 agents with these prompts (filling in placeholders from Steps 1-3):

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

## Step 5: Spawn Review Merger

After all 3 code-reviewer agents return, spawn 1 `review-merger` agent (subagent_type: `review-merger`, model: `sonnet`).

Pass only scope metadata and the session directory — the merger reads findings from temp files via MCP:

```
REVIEW_MODE: code-review
SCOPE: [SCOPE]
BASE: [BASE or "N/A"]
PATHS: [PATHS or "N/A"]
PR: [PR_NUMBER or "N/A"]
PLAN_FILE: [PLAN_FILE_PATH]
PHASE: N/A
REVIEWER_MODEL: [REQUESTED_MODEL]
FOCUS_AREAS: correctness, security, quality
SESSION_DIR: [SESSION_DIR]
```

The merger will:
1. Load findings from the session directory via `mcp__review-tools__read_all_findings`
2. Fetch the diff independently for validation
3. Re-read source files to verify each finding
4. Filter false positives, deduplicate across reviewers
5. Produce final structured feedback

## Step 6: Present Results

**CRITICAL: Output the merger's feedback VERBATIM.** Do NOT summarize, condense, or reformat it. The merger produces detailed structured output with per-issue descriptions, locations, and suggested fixes — the user needs ALL of that detail to make informed decisions. Do NOT compress issues into a summary table with one-line descriptions.

If the merger's output is missing or empty, say so. Otherwise, paste it through exactly as returned.

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
