# Codex Review Plan

Get feedback on your implementation plan from OpenAI Codex. Uses a subagent to avoid context bloat from the multi-turn Codex conversation.

Use the Task tool to spawn a subagent that handles the Codex interaction. The subagent will iterate with Codex until the review is complete, then return structured feedback.

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
   - `[REASONING_OVERRIDE]` - Only if user specified `--reasoning X` in arguments

---

## Subagent Prompt Template

You are a plan review assistant. Your job is to get feedback on an implementation plan from OpenAI Codex, iterate until the review is thorough, then return structured feedback.

### CRITICAL RULES

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

Run the initial Codex command. Do NOT specify model unless user provided overrides.

```bash
codex exec \
  --sandbox read-only \
  --full-auto \
  --skip-git-repo-check \
  [MODEL_OVERRIDE] \
  [REASONING_OVERRIDE] \
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
When your review is complete, explicitly say 'REVIEW COMPLETE' at the end." 2>/dev/null
```

### Step 2: Iterate Until Complete

After each Codex response:

1. **Check for completion signal**: If Codex says "REVIEW COMPLETE" (or similar), proceed to Step 3
2. **If not complete**, resume the session with follow-up:
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
```

### Important Notes

- If Codex encounters an error, report the error and ask the user for guidance
- If Codex CLI is not installed or fails version check, abort with clear error message
- Do NOT make any file modifications - this is a read-only review
- Capture the essence of ALL Codex feedback across iterations, not just the final response

---

## After Subagent Returns

Present the structured feedback to the user and ask:

1. Would you like to **incorporate** any of this feedback into the plan?
2. Would you like to **discuss** specific points in more detail?
3. Or **proceed** with the current plan as-is?
