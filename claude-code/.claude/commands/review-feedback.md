Review and triage PR feedback, distinguishing valid suggestions from those based on incorrect assumptions (especially from Copilot).

## Step 1: Parse PR URL

Parse the GitHub PR URL from `$ARGUMENTS` to extract:
- **owner**: Repository owner/organization
- **repo**: Repository name
- **pullNumber**: PR number

URL format: `https://github.com/{owner}/{repo}/pull/{pullNumber}`

If URL is missing or invalid, ask for a valid GitHub PR URL.

## Step 2: Fetch PR Data

Use `mcp__MCP_DOCKER__pull_request_read` to gather:

1. `method: "get"` - PR details and description
2. `method: "get_diff"` - The actual code changes
3. `method: "get_reviews"` - Overall PR reviews
4. `method: "get_review_comments"` - Line-by-line code comments
5. `method: "get_comments"` - General discussion comments

## Step 3: Analyze Feedback with Sub-agents

Spawn 2-3 sub-agents IN PARALLEL to scrutinize the feedback.

### Thinking Levels for Sub-agents

Each sub-agent should use extended thinking. Choose the level based on feedback complexity:

| Level | When to Use |
|-------|-------------|
| `think` | Simple, obvious feedback (formatting, typos) |
| `think hard` | Standard feedback requiring codebase verification |
| `think harder` | Complex feedback with architectural implications |
| `ultrathink` | Ambiguous feedback, conflicting suggestions, or when unsure |

**Default to "think hard"** - most PR feedback requires careful verification.

### Agent Assignments

**Agent 1: Code Quality & Style**
- Analyze feedback about: naming, formatting, best practices, patterns
- Verify against actual project conventions
- Check if suggestions align with codebase style
- Thinking: Use "think" for obvious items, "think hard" for debatable ones

**Agent 2: Logic & Architecture**
- Analyze feedback about: bugs, edge cases, design, structure
- Verify the reviewer's assumptions against actual code
- Check if they understand the system context correctly
- Thinking: Use "think harder" or "ultrathink" - these require deep analysis

**Agent 3 (if needed): Tests & Docs**
- Analyze feedback about: test coverage, documentation
- Verify if suggestions are appropriate for this project
- Thinking: Use "think hard" - need to understand project testing patterns

### Agent Requirements

Each agent must:
1. **Read the relevant codebase** to verify the reviewer's assumptions
2. **Use extended thinking** at the appropriate level
3. **Categorize each feedback item** as:
   - ✅ **Valid** - Correct understanding, should address
   - ⚠️ **Partial** - Partially correct, needs nuance
   - ❌ **Invalid** - Based on wrong assumptions, explain why
4. **Explain their reasoning** for each categorization

## Step 4: Synthesize and Present Plan (Do NOT auto-implement)

After sub-agents complete, synthesize their findings. If any feedback items are ambiguous or agents disagreed, use "ultrathink" to resolve.

### ✅ Valid Feedback - Action Plan
For each valid item:
- What to change
- Which file(s)
- Priority (high/medium/low)

### ❌ Invalid Feedback - Explanations
For each invalid item:
- What assumption was wrong
- What the actual context is
- Why it should be ignored

### Summary
- Total feedback items reviewed
- Valid vs invalid breakdown
- Recommended next steps

**Wait for user approval before implementing any changes.**

## Key Principles

- **Copilot lacks context** - It makes assumptions about the system that may be wrong
- **Verify before accepting** - Always check the codebase
- **Explain rejections** - Document why feedback is invalid
- **Plan only** - Present analysis, don't auto-fix

<task>$ARGUMENTS</task>
