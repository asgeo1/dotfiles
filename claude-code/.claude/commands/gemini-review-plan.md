# Gemini Review Plan

Get feedback on your implementation plan from Google Gemini. Uses a subagent to avoid context bloat from the multi-turn Gemini conversation.

Use the Task tool to spawn a subagent that handles the Gemini interaction. The subagent will iterate with Gemini until the review is complete, then return structured feedback.

⚠️ **CRITICAL: Pass the prompt below VERBATIM to the subagent. DO NOT summarize, paraphrase, or truncate.**

## Before Spawning the Subagent

1. **Parse arguments from `$ARGUMENTS`:**
   - Check for `--model X` flag, remove from args
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
   - If user specified `--model X` in arguments, use that as `[REQUESTED_MODEL]`
   - Otherwise, default to `gemini-pro-latest` as `[REQUESTED_MODEL]`
   - This ensures we always explicitly request the best available model

5. **Construct the subagent prompt** using the template below, filling in:
   - `[PLAN_CONTENT]` - The actual plan markdown
   - `[GIT_STATUS]` - Output from git status
   - `[RELEVANT_FILES]` - List of file paths mentioned in the plan
   - `[REQUESTED_MODEL]` - The model to use (user-specified or default)

---

## Subagent Prompt Template

You are a plan review assistant. Your job is to get feedback on an implementation plan from Google Gemini, iterate until the review is thorough, then return structured feedback.

### CRITICAL RULES

0. **NO CD, NO GIT -C** - You are already in the correct working directory. Do NOT `cd`, do NOT use `git -C /path`. Just run commands directly. The ONLY Bash commands you should run are the `gemini` commands shown below - nothing else.
1. **DEFAULT APPROVAL MODE** - Use default approval mode (Gemini will read files as needed)
2. **ITERATE UNTIL COMPLETE** - Keep conversing with Gemini until it signals the review is done
3. **STRUCTURED OUTPUT** - Return feedback in the exact format specified

### Context

**Plan to Review:**
```markdown
[PLAN_CONTENT]
```

**Current Git Status:**
```
[GIT_STATUS]
```

**Relevant Files (Gemini can read these as needed):**
[RELEVANT_FILES]

### Step 1: Start Gemini Session

Run the initial Gemini command:

```bash
gemini -m [REQUESTED_MODEL] "Review the following implementation plan. Analyze it in the context of this codebase.

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
When your review is complete, explicitly say 'REVIEW COMPLETE' at the end."
```

### Step 1b: Capture Model Info

After receiving Gemini's initial response:
- Look for a `MODEL_ID: ...` line in the output
- Store the reported model as `[CONFIRMED_MODEL]`
- If no MODEL_ID line found, set `[CONFIRMED_MODEL]` to "unknown (not reported)"

### Step 2: Iterate Until Complete

After each Gemini response:

1. **Check for completion signal**: If Gemini says "REVIEW COMPLETE" (or similar), proceed to Step 3
2. **If not complete**, resume the session with `--resume latest`:
   ```bash
   gemini --resume latest "Continue your review. If you have more concerns, suggestions, or questions, share them. Read additional files if needed. Say 'REVIEW COMPLETE' when done."
   ```
3. **Repeat** until Gemini signals completion (max 5 iterations to prevent runaway)

### Step 3: Synthesize Feedback

Once Gemini completes the review, synthesize ALL feedback from the entire conversation into this exact format:

```markdown
## Gemini Plan Review Feedback

### Concerns
- [List any critical issues, risks, or problems Gemini identified]
- [If none: "No significant concerns identified"]

### Suggestions
- [List improvements or alternatives Gemini proposed]
- [If none: "No additional suggestions"]

### Questions
- [List any clarifications Gemini thinks are needed before implementation]
- [If none: "No clarifying questions"]

### Overall Assessment
[Brief 2-3 sentence summary of Gemini's overall opinion on the plan]

**Recommendation:** [proceed | revise | needs-discussion]

## Models Used
- **Gemini requested:** [REQUESTED_MODEL]
- **Gemini confirmed:** [CONFIRMED_MODEL]
- **Claude subagent:** [self-report your model name/version]
```

### Important Notes

- If Gemini hits quota errors or the requested model is unavailable:
  1. Retry with `-m gemini-2.5-flash`
  2. Note in Models Used: "gemini-2.5-flash (fallback from [REQUESTED_MODEL] due to quota)"
  3. Still capture MODEL_ID from Gemini's response
- If Gemini CLI is not installed or fails version check, abort with clear error message
- Do NOT make any file modifications - this is a read-only review
- Capture the essence of ALL Gemini feedback across iterations, not just the final response

---

## After Subagent Returns

Present the structured feedback to the user. **Always include the "Models Used" section** so the user can see what models were used.

If the Gemini confirmed model differs from what was requested, highlight this discrepancy.

Then ask:

1. Would you like to **incorporate** any of this feedback into the plan?
2. Would you like to **discuss** specific points in more detail?
3. Or **proceed** with the current plan as-is?
