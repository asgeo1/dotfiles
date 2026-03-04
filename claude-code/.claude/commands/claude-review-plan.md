# Claude Review Plan

Get feedback on your implementation plan from a principal engineer agent. The agent reads the plan file, explores the codebase for context, and provides an advisory assessment with concerns, suggestions, questions, and a recommendation.

**Flags:**
- `--model X` - Override the reviewer model (default: opus)

**Usage:** `/claude-review-plan <plan_path> [--model X]`

---

## Step 1: Parse Arguments

Parse `$ARGUMENTS` to extract the plan file path and flags:

```
$ARGUMENTS = "$ARGUMENTS"
```

**Flag detection:**
- Check for `--model X` flag (X is the next token after --model), remove from args
- If user specified `--model X`, use that as `[REQUESTED_MODEL]`
- Otherwise, default to `opus` as `[REQUESTED_MODEL]`
- Valid models: `opus`, `sonnet`, `haiku`, or full model IDs

**Plan file detection:**
- If remaining argument contains a file path → use that as `[PLAN_FILE_PATH]`
- Otherwise, check if you're in plan mode and have a plan file path in context
- If neither → ABORT: "Cannot review without a plan. Please specify a plan file path."

## Step 2: Gather Context (brief)

Gather minimal supplementary context from the conversation — do NOT read the plan file yourself:

1. **Supplementary context**: From your conversation, extract relevant info:
   - Specific user concerns mentioned
   - Design decisions discussed verbally
   - Areas of uncertainty
   - Constraints not documented in the plan

Store as `[SUPPLEMENTARY_CONTEXT]` or "none".

## Step 3: Spawn Principal Engineer

Use the Agent tool to spawn a `principal-engineer` agent (subagent_type: `principal-engineer`, model: `[REQUESTED_MODEL]`). **Do NOT read or pass the plan content** — just pass the path. The agent will read it.

Pass the following prompt, filling in placeholders:

```
PLAN_FILE: [PLAN_FILE_PATH]
SUPPLEMENTARY_CONTEXT: [SUPPLEMENTARY_CONTEXT]
```

The principal engineer will:
1. Read the plan file at the provided path
2. Explore the codebase for context
3. Assess the plan for architectural soundness, completeness, simplicity, risks, and alignment
4. Return a structured review with concerns, suggestions, questions, and a recommendation

## Step 4: Present Results

After the agent returns, present its structured feedback to the user.

Then ask:
1. Would you like to **incorporate** any of this feedback into the plan?
2. Would you like to **discuss** specific points in more detail?
3. Or **proceed** with the current plan as-is?
