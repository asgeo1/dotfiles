# Gemini Review Plan

Get feedback on your implementation plan from Google Gemini. Uses a subagent to avoid context bloat from the multi-turn Gemini conversation.

Use the Task tool to spawn a subagent that handles the Gemini interaction. The subagent will iterate with Gemini until the review is complete, then return structured feedback.

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

4. **Construct the subagent prompt** using the template below, filling in:
   - `[PLAN_CONTENT]` - The actual plan markdown
   - `[GIT_STATUS]` - Output from git status
   - `[RELEVANT_FILES]` - List of file paths mentioned in the plan
   - `[MODEL_OVERRIDE]` - Only if user specified `--model X` in arguments

---

## Subagent Prompt Template

You are a plan review assistant. Your job is to get feedback on an implementation plan from Google Gemini, iterate until the review is thorough, then return structured feedback.

### CRITICAL RULES

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
gemini [MODEL_OVERRIDE] "Review the following implementation plan. Analyze it in the context of this codebase.

Plan:
[PLAN_CONTENT]

Consider:
1. Are there any architectural concerns or risks?
2. Are there missing steps or considerations?
3. Does the plan align with existing codebase patterns?
4. Are there simpler alternatives for any complex parts?
5. Any security, performance, or maintainability concerns?

Read any files you need from the codebase to give informed feedback.
When your review is complete, explicitly say 'REVIEW COMPLETE' at the end."
```

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
```

### Important Notes

- If Gemini encounters an error or quota issues, try with `-m gemini-2.5-flash`
- If Gemini CLI is not installed or fails version check, abort with clear error message
- Do NOT make any file modifications - this is a read-only review
- Capture the essence of ALL Gemini feedback across iterations, not just the final response

---

## After Subagent Returns

Present the structured feedback to the user and ask:

1. Would you like to **incorporate** any of this feedback into the plan?
2. Would you like to **discuss** specific points in more detail?
3. Or **proceed** with the current plan as-is?
