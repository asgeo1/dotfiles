Review and triage PR feedback, distinguishing valid suggestions from those based on incorrect assumptions (especially from Copilot).

## Step 1: Parse PR URL

Parse the GitHub PR URL from `$ARGUMENTS`. The URL can be in two formats:

### Format A: All Feedback
```
https://github.com/{owner}/{repo}/pull/{pullNumber}
```
Extract: `owner`, `repo`, `pullNumber`
Behavior: Review ALL feedback on the PR (all reviews, all comments)

### Format B: Specific Review
```
https://github.com/{owner}/{repo}/pull/{pullNumber}#pullrequestreview-{reviewId}
```
Extract: `owner`, `repo`, `pullNumber`, `reviewId`
Behavior: Review ONLY the feedback from that specific review

### How to detect the format:
- If URL contains `#pullrequestreview-` → Format B (specific review)
- Otherwise → Format A (all feedback)

If URL is missing or invalid, ask for a valid GitHub PR URL.

## Step 2: Fetch PR Data

Use `mcp__MCP_DOCKER__pull_request_read` to gather data.

### For Format A (All Feedback):
Fetch everything:
1. `method: "get"` - PR details and description
2. `method: "get_diff"` - The actual code changes
3. `method: "get_reviews"` - All PR reviews
4. `method: "get_review_comments"` - All line-by-line code comments
5. `method: "get_comments"` - All general discussion comments

**Skip previously addressed feedback**: Check `~/.claude/plans/` for existing plan files matching this PR (e.g., `pr-feedback-{owner}-{repo}-{pullNumber}*.md`). If found:
- Read the existing plan(s)
- Skip any feedback items that were already categorized and addressed
- Only analyze NEW feedback since the last analysis
- Mention in the summary: "Skipped X items already addressed in previous analysis"

### For Format B (Specific Review):
Fetch selectively:
1. `method: "get"` - PR details and description
2. `method: "get_diff"` - The actual code changes
3. `method: "get_reviews"` - Find the specific review matching `reviewId`
4. `method: "get_review_comments"` - Filter to ONLY comments from that review

**Important for Format B**: After fetching, filter the results to include only feedback from the specific `reviewId`. Ignore all other reviews and comments not associated with that review.

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

## Step 4: Write Plan to File

**IMPORTANT**: You MUST write the plan to a file. Use the standard Claude Code plans location:

```
~/.claude/plans/pr-feedback-{owner}-{repo}-{pullNumber}.md
```

Example: `~/.claude/plans/pr-feedback-bluefrogsoftware-guitarcharts-20.md`

After sub-agents complete, synthesize their findings. If any feedback items are ambiguous or agents disagreed, use "ultrathink" to resolve.

**Write the following structure to the plan file:**

```markdown
# PR Feedback Analysis: {owner}/{repo}#{pullNumber}

## ✅ Valid Feedback - Action Plan

| Priority | File | Change | Feedback Source |
|----------|------|--------|-----------------|
| high/medium/low | path/to/file.ts | What to change | Copilot/User |

## ⚠️ Partial Feedback - Requires Discussion

| File | Suggestion | Why Partial | Recommendation |
|------|------------|-------------|----------------|

## ❌ Invalid Feedback - Do Not Change

| Suggestion | Why Invalid | Actual Context |
|------------|-------------|----------------|

## Summary

- Total feedback items: X
- Valid: X | Partial: X | Invalid: X
- Recommended next steps: ...

## Resolution Actions (execute on user approval)

### Valid Items - Reply after implementing fix:
| Comment ID | File:Line | Reply Text |
|------------|-----------|------------|
| 123456789 | src/foo.ts:42 | "Fixed - [brief description of change]" |

### Invalid Items - Reply with explanation:
| Comment ID | File:Line | Reply Text |
|------------|-----------|------------|
| 987654321 | src/bar.ts:15 | "Not applicable - [explanation of why this suggestion doesn't apply]" |

### Partial Items - Reply with context:
| Comment ID | File:Line | Reply Text |
|------------|-----------|------------|
| 456789123 | src/baz.ts:30 | "Partially addressed - [what was done and what wasn't, with reasoning]" |
```

## Step 5: Present Summary (Do NOT auto-implement)

After writing the plan file:
1. Tell the user the plan file location
2. Show a brief summary of valid vs invalid items
3. **Wait for user approval before implementing any changes**

Ask: "Ready to implement fixes and resolve feedback? Say 'go ahead' or 'implement' when ready."

## Step 6: Execute Resolution (on user approval)

**Only execute when user says**: "go ahead", "implement", "resolve", or similar approval.

### 6a. Implement Code Changes
For each ✅ Valid item:
1. Make the code change as specified in the action plan
2. Verify the change is correct

### 6b. Post Resolution Comments
For each feedback item (valid, invalid, or partial), post a reply comment to the PR:

**Use these MCP tools:**
- `mcp__MCP_DOCKER__add_issue_comment` - For general PR comments
- `mcp__MCP_DOCKER__pull_request_review_write` with `method: "create"` - For review responses

**Reply format by category:**
- ✅ **Valid**: "Fixed - [description of what was changed]"
- ❌ **Invalid**: "Not applicable - [explanation of why this doesn't apply to this codebase]"
- ⚠️ **Partial**: "Partially addressed - [what was done and reasoning for what wasn't]"

### 6c. Attempt to Resolve Conversations
After posting replies, attempt to resolve each conversation if the API supports it.
If resolution is not available via API, the reply comment serves as the resolution record.

### 6d. Report Summary
After completing all actions:
```
Resolution Complete:
- ✅ X items fixed and resolved
- ❌ X items marked as not applicable (with explanation)
- ⚠️ X items partially addressed

All feedback has been responded to on the PR.
```

## Key Principles

### Feedback from `asgeo1` is NEVER invalid
Feedback from user `asgeo1` must be treated as a direct instruction from the user. Do NOT:
- Question it
- Mark it as invalid
- Scrutinize it like Copilot feedback

Always categorize `asgeo1` feedback as ✅ **Valid** and include it in the action plan.

### For all other feedback sources (Copilot, other users):
- **Copilot lacks context** - It makes assumptions about the system that may be wrong
- **Verify before accepting** - Always check the codebase
- **Explain rejections** - Document why feedback is invalid

### General:
- **Plan only** - Present analysis, don't auto-fix

<task>$ARGUMENTS</task>
