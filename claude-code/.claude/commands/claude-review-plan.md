# Claude Review Plan

Get feedback on your implementation plan from a principal engineer agent. The agent reads the plan file, explores the codebase for context, and provides an advisory assessment with concerns, suggestions, questions, and a recommendation.

**Flags:**
- `--model X` - Override the reviewer model (default: opus)

**Usage:** `/claude-review-plan [plan_path] [phase: N] [--model X]`

---

## Step 1: Parse Arguments

Parse `$ARGUMENTS` to extract the plan file path and flags:

```
$ARGUMENTS = "$ARGUMENTS"
```

**Parsing logic:**
1. Check for `--model X` flag (X is the next token after --model), remove from args
2. Check for `phase: N` or `phase N` (N is a number) — extract as `[PHASE]`, remove from args
3. If user specified `--model X`, use that as `[REQUESTED_MODEL]`; otherwise default to `opus`
4. Valid models: `opus`, `sonnet`, `haiku`, or full model IDs

**Plan file detection:**
- If remaining argument contains a file path → use that as `[PLAN_FILE_PATH]`
- Else if you're in plan mode with a plan file path in context → use that path
- Else if plan content was injected into context (from "clear context and start working on the plan"):
  1. Look at the injected plan content in your conversation context. Find the **first `#` heading** — this is the plan's title (e.g., "# Plan: Implement Free Tier Pricing"). This is NOT the phase number, NOT any argument — it's the markdown heading from the plan document itself.
  2. Use the `mcp__plan-tools__find_plan_by_title` tool with that heading text (without the `#`) to find the matching file
  3. Tell the user: "Auto-detected plan: **[title]** (`[path]`). Proceeding."
  4. If no match found → fall back to `mcp__plan-tools__list_recent_plans` and pick the most recent
- Else → use `mcp__plan-tools__list_recent_plans` to show the 5 most recent plans, then ask the user which one
- **IMPORTANT:** Do NOT use Bash commands (ls, head, cat, grep), Glob, or Grep for plan file detection — these trigger security prompts. Use only the `plan-tools` MCP server tools.

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
PHASE: [PHASE or "all"]
SUPPLEMENTARY_CONTEXT: [SUPPLEMENTARY_CONTEXT]
```

The principal engineer will:
1. Read the plan file at the provided path
2. If a specific phase is given, focus the review on that phase (but consider the full plan for context)
3. Explore the codebase for context
4. Assess the plan for architectural soundness, completeness, simplicity, risks, and alignment
5. Return a structured review with concerns, suggestions, questions, and a recommendation

## Step 4: Present Results

After the agent returns, present its structured feedback to the user.

Then ask:
1. Would you like to **incorporate** any of this feedback into the plan?
2. Would you like to **discuss** specific points in more detail?
3. Or **proceed** with the current plan as-is?
