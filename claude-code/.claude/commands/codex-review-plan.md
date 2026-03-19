# Codex Review Plan

Get feedback on your implementation plan from OpenAI Codex. Uses a subagent to avoid context bloat from the multi-turn Codex conversation.

Use the Task tool to spawn a subagent that handles the Codex interaction. The subagent will iterate with Codex until the review is complete, then return structured feedback.

⚠️ **CRITICAL: Pass the prompt below VERBATIM to the subagent. DO NOT summarize, paraphrase, or truncate.**

## Before Spawning the Subagent

1. **Parse arguments from `$ARGUMENTS`:**
   - Check for `--model X` flag, remove from args
   - Check for `--reasoning X` flag, remove from args
   - Check for `phase: N` or `phase N` (N is a number) — extract as `[PHASE]`, remove from args

2. **Determine the plan file path:**
   - If remaining argument contains a file path, use that
   - Else if you're in plan mode with a plan file path in context → use that path
   - Else if plan content was injected into context (from "clear context and start working on the plan"):
     1. Look at the injected plan content in your conversation context. Find the **first `#` heading** — this is the plan's title. This is NOT the phase number, NOT any argument — it's the markdown heading from the plan document itself.
     2. Use the `mcp__plan-tools__find_plan_by_title` tool with that heading text (without the `#`) to find the matching file
     3. Tell the user: "Auto-detected plan: **[title]** (`[path]`). Proceeding."
     4. If no match found → fall back to `mcp__plan-tools__list_recent_plans` and pick the most recent
   - Else → use `mcp__plan-tools__list_recent_plans` to show the 5 most recent plans, then ask the user which one
   - **IMPORTANT:** Do NOT use Bash commands (ls, head, cat, grep), Glob, or Grep for plan file detection — these trigger security prompts. Use only the `plan-tools` MCP server tools.

2. **Gather context (do this BEFORE spawning):**
   ```bash
   # Get current repo state (brief summary)
   git status --short
   ```

3. **Read the plan file** using `mcp__plan-tools__read_plan` (pass the file path). **Do NOT use the Read tool or bash commands** — they trigger security prompts. Extract:
   - The plan content itself
   - Any file paths mentioned in the plan

4. **Determine model:**
   - If user specified `--model X` in arguments, store as `[REQUESTED_MODEL]` and set `[MODEL_FLAG]` to `--model X`
   - Otherwise, `[REQUESTED_MODEL]` = "default" and `[MODEL_FLAG]` = "" (empty, use Codex CLI's default)
   - If user specified `--reasoning X`, store as `[REASONING_OVERRIDE]`

5. **Construct the subagent prompt** using the template below, filling in:
   - `[PLAN_CONTENT]` - The actual plan markdown
   - `[GIT_STATUS]` - Output from git status
   - `[RELEVANT_FILES]` - List of file paths mentioned in the plan
   - `[MODEL_FLAG]` - The --model flag (or empty if using default)
   - `[REQUESTED_MODEL]` - The model name for reporting
   - `[REASONING_OVERRIDE]` - The --reasoning flag if specified

---

## Subagent Prompt Template

You are a plan review assistant. Your job is to get feedback on an implementation plan from OpenAI Codex, iterate until the review is thorough, then return structured feedback.

### CRITICAL RULES

0. **NO CD, NO GIT -C** - You are already in the correct working directory. Do NOT `cd`, do NOT use `git -C /path`. Just run commands directly. The ONLY Bash commands you should run are the `codex exec` commands shown below - nothing else.
1. **READ-ONLY SANDBOX** - Always use `--sandbox read-only` with Codex
2. **SUPPRESS THINKING** - Always append `2>/dev/null` to codex commands
3. **ITERATE UNTIL COMPLETE** - Keep conversing with Codex until it signals the review is done
4. **STRUCTURED OUTPUT** - Return feedback in the exact format specified

### Context

**Plan to Review:**
```markdown
[PLAN_CONTENT]
```

**Current Git Status:**
```
[GIT_STATUS]
```

**Relevant Files (Codex can read these as needed):**
[RELEVANT_FILES]

### Step 1: Start Codex Session

Run the initial Codex command:

```bash
codex exec \
  --sandbox read-only \
  --full-auto \
  --skip-git-repo-check \
  [MODEL_FLAG] \
  [REASONING_OVERRIDE] \
  "Review the following implementation plan. Analyze it in the context of this codebase.

[IF PHASE != 'all']
Focus your review on **Phase [PHASE]** of the plan, but read the full plan for context.
[END IF]

Plan:
[PLAN_CONTENT]

Consider:
1. Are there any architectural concerns or risks?
2. Are there missing steps or considerations?
3. Does the plan align with existing codebase patterns?
4. Are there simpler alternatives for any complex parts?
5. Any security, performance, or maintainability concerns?

Read any files you need from the codebase to give informed feedback.

Before your review, state: 'MODEL_ID: [your model name/version]'
When your review is complete, explicitly say 'REVIEW COMPLETE' at the end." 2>/dev/null
```

### Step 1b: Capture Model Info

After receiving Codex's initial response:
- Look for a `MODEL_ID: ...` line in the output
- Store the reported model as `[CONFIRMED_MODEL]`
- If no MODEL_ID line found, set `[CONFIRMED_MODEL]` to "unknown (not reported)"

### Step 2: Iterate Until Complete

After each Codex response:

1. **Check for completion signal**: If Codex says "REVIEW COMPLETE" (or similar), proceed to Step 3
2. **If not complete**, resume the session with `--last`:
   ```bash
   echo "Continue your review. If you have more concerns, suggestions, or questions, share them. Read additional files if needed. Say 'REVIEW COMPLETE' when done." | codex exec --skip-git-repo-check resume --last 2>/dev/null
   ```
3. **Repeat** until Codex signals completion (max 5 iterations to prevent runaway)

### Step 3: Synthesize Feedback

Once Codex completes the review, synthesize ALL feedback from the entire conversation into this exact format:

```markdown
## Codex Plan Review Feedback

### Concerns
- [List any critical issues, risks, or problems Codex identified]
- [If none: "No significant concerns identified"]

### Suggestions
- [List improvements or alternatives Codex proposed]
- [If none: "No additional suggestions"]

### Questions
- [List any clarifications Codex thinks are needed before implementation]
- [If none: "No clarifying questions"]

### Overall Assessment
[Brief 2-3 sentence summary of Codex's overall opinion on the plan]

**Recommendation:** [proceed | revise | needs-discussion]

## Models Used
- **Codex requested:** [REQUESTED_MODEL]
- **Codex confirmed:** [CONFIRMED_MODEL]
- **Claude subagent:** [self-report your model name/version]
```

### Important Notes

- If Codex encounters model errors or the requested model is unavailable:
  1. Retry without --model flag (use CLI default)
  2. Note in Models Used: "default (fallback from [REQUESTED_MODEL])"
  3. Still capture MODEL_ID from Codex's response
- If Codex CLI is not installed or fails version check, abort with clear error message
- Do NOT make any file modifications - this is a read-only review
- Capture the essence of ALL Codex feedback across iterations, not just the final response

---

## After Subagent Returns

**CRITICAL: Output the subagent's feedback VERBATIM.** Do NOT summarize, condense, or reformat it. The subagent produces detailed structured output with concerns, suggestions, and architectural analysis — the user needs ALL of that detail to make informed decisions. Do NOT compress findings into a summary table with one-line descriptions.

If the subagent's output is missing or empty, say so. Otherwise, paste it through exactly as returned.

**Always include the "Models Used" section** so the user can see what models were used. If the Codex confirmed model differs from what was requested, highlight this discrepancy.

**Save findings for triage:** After outputting the review verbatim, save the complete output using `mcp__plan-tools__write_plan`.

**File naming:**
- Extract the plan slug from the plan file path (filename without `.md`)
- Write to `~/.claude/plans/{plan-slug}-plan-review-round-1.md`
- If `round-1` already exists, use `round-2`, `round-3`, etc.
- Use `mcp__plan-tools__find_plan_by_title` to check for existing rounds

**Prepend YAML frontmatter** with: `title` ("Plan Review - {plan title} - Round N"), `date` (current ISO date), `review_type` ("plan-review"), and `source_plan` (path to original plan file).

This enables the `/triage-review` command to process findings interactively.

After presenting the full output, ask:
1. Would you like to **discuss** any concerns?
2. Would you like me to **revise** the plan (or run `/triage-review` to go through findings one-by-one)?
3. Or **proceed** with implementation?
