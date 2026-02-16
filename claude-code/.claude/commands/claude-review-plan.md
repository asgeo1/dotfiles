# Claude Review Plan

Get feedback on your implementation plan from a separate Claude Code instance. Uses a subagent to avoid context bloat from the multi-turn conversation.

Use the Task tool to spawn a subagent that handles the external Claude interaction. The subagent will iterate with Claude until the review is complete, then return structured feedback.

⚠️ **CRITICAL: Pass the prompt below VERBATIM to the subagent. DO NOT summarize, paraphrase, or truncate.**

## Before Spawning the Subagent

1. **Determine the plan file path:**
   - If `$ARGUMENTS` contains a file path, use that
   - Otherwise, check if you're in plan mode and have a plan file path in context
   - If neither, ABORT with: "Cannot review without a plan. Please specify a plan file path."

2. **Gather context (do this BEFORE spawning):**
   ```bash
   # Get current repo state (brief summary)
   git status --short
   ```

3. **Read the plan file** and extract:
   - The plan content itself
   - Any file paths mentioned in the plan

4. **Determine model:**
   - If user specified `--model X` in arguments, use that as `[REQUESTED_MODEL]`
   - Otherwise, default to `opus` as `[REQUESTED_MODEL]`
   - Valid models: `opus`, `sonnet`, `haiku`, or full model IDs

5. **Construct the subagent prompt** using the template below, filling in:
   - `[PLAN_CONTENT]` - The actual plan markdown
   - `[GIT_STATUS]` - Output from git status
   - `[RELEVANT_FILES]` - List of file paths mentioned in the plan
   - `[REQUESTED_MODEL]` - The model to use (user-specified or default)

---

## Subagent Prompt Template

You are a plan review assistant. Your job is to get feedback on an implementation plan from an external Claude Code instance, iterate until the review is thorough, then return structured feedback.

### CRITICAL RULES

0. **NO CD, NO GIT -C** - You are already in the correct working directory. Do NOT `cd`, do NOT use `git -C /path`. Just run commands directly. The ONLY Bash commands you should run are the `env -u CLAUDECODE claude` commands shown below - nothing else.
1. **READ-ONLY** - The external Claude runs with write tools disabled
2. **ITERATE UNTIL COMPLETE** - Keep conversing with Claude until it signals the review is done
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

**Relevant Files (Claude can read these as needed):**
[RELEVANT_FILES]

### Step 1: Start Claude Session

Run the initial Claude command:

```bash
env -u CLAUDECODE claude -p \
  --model [REQUESTED_MODEL] \
  --dangerously-skip-permissions \
  --disallowedTools "Edit,Write,NotebookEdit" \
  "Review the following implementation plan. Analyze it in the context of this codebase.

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

**IMPORTANT:** `env -u CLAUDECODE` unsets the nesting-detection env var so Claude Code CLI can run from within Claude Code.

### Step 1b: Capture Model Info

After receiving Claude's initial response:
- Look for a `MODEL_ID: ...` line in the output
- Store the reported model as `[CONFIRMED_MODEL]`
- If no MODEL_ID line found, set `[CONFIRMED_MODEL]` to "unknown (not reported)"

### Step 2: Iterate Until Complete

After each Claude response:

1. **Check for completion signal**: If Claude says "REVIEW COMPLETE" (or similar), proceed to Step 3
2. **If not complete**, resume the session with `--continue`:
   ```bash
   CLAUDECODE= claude -p --continue \
     --dangerously-skip-permissions \
     --disallowedTools "Edit,Write,NotebookEdit" \
     "Continue your review. If you have more concerns, suggestions, or questions, share them. Read additional files if needed. Say 'REVIEW COMPLETE' when done."
   ```
3. **Repeat** until Claude signals completion (max 5 iterations to prevent runaway)

### Step 3: Synthesize Feedback

Once Claude completes the review, synthesize ALL feedback from the entire conversation into this exact format:

```markdown
## Claude Plan Review Feedback

### Concerns
- [List any critical issues, risks, or problems Claude identified]
- [If none: "No significant concerns identified"]

### Suggestions
- [List improvements or alternatives Claude proposed]
- [If none: "No additional suggestions"]

### Questions
- [List any clarifications Claude thinks are needed before implementation]
- [If none: "No clarifying questions"]

### Overall Assessment
[Brief 2-3 sentence summary of Claude's overall opinion on the plan]

**Recommendation:** [proceed | revise | needs-discussion]

## Models Used
- **Claude (external) requested:** [REQUESTED_MODEL]
- **Claude (external) confirmed:** [CONFIRMED_MODEL]
- **Claude subagent:** [self-report your model name/version]
```

### Important Notes

- If the requested model is unavailable or errors occur:
  1. Retry with `--model haiku` as fallback
  2. Note in Models Used: "haiku (fallback from [REQUESTED_MODEL])"
  3. Still capture MODEL_ID from Claude's response
- If Claude CLI is not installed or fails, abort with clear error message
- Do NOT make any file modifications - this is a read-only review
- Capture the essence of ALL Claude feedback across iterations, not just the final response

---

## After Subagent Returns

Present the structured feedback to the user. **Always include the "Models Used" section** so the user can see what models were used.

If the Claude confirmed model differs from what was requested, highlight this discrepancy.

Then ask:

1. Would you like to **incorporate** any of this feedback into the plan?
2. Would you like to **discuss** specific points in more detail?
3. Or **proceed** with the current plan as-is?
