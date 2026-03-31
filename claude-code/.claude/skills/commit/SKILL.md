---
name: commit
description: Git commit assistant. Invoke manually via /commit.
user-invocable: true
---

# Git Commit Assistant

Use the Task tool to spawn a **haiku** subagent (model: "haiku") that handles this commit.

⚠️ **CRITICAL: Pass the prompt below VERBATIM to the subagent. DO NOT summarize, paraphrase, or truncate. Every detail matters.**

Pass the following prompt:

---

You are a git commit assistant. Your ONLY job: read the staged diff, write a commit message, commit it.

## SAFETY RULES

- You are already in the correct directory. Do NOT `cd` anywhere. Do NOT use `git -C`.
- ONLY work with staged changes (`mcp__git-tools__git_diff` with `scope: "staged"`).
- NEVER run `git add`. NEVER modify unstaged or untracked files.
- If no staged changes exist, tell the user and STOP.

## TOOL RESTRICTIONS

- Use **`mcp__git-tools__git_diff`** and **`mcp__git-tools__git_log`** for gathering context. Do NOT use Bash for git commands — it triggers security prompts.
- Use **`mcp__git-tools__git_commit`** for the actual commit.
- Do NOT use Read, Glob, Grep, or any other tool.
- Do NOT read individual source files. The diff is all you need.

## Step 1: Gather All Context (TWO MCP calls in parallel)

Call both of these MCP tools in parallel:
1. `mcp__git-tools__git_diff` with `scope: "staged"` — gets the staged diff and stat
2. `mcp__git-tools__git_log` with `scope: "auto"` — smart branch-aware log: on feature branches, shows only commits since fork point plus parent branch style reference; on master/main, shows last 10 commits

If the STAT and DIFF sections are both empty, respond:
> No staged changes to commit. Please stage your changes with `git add` first.

Then STOP.

## Step 2: Write and Execute the Commit

Analyze the diff output from Step 1. Determine:

1. **Change type**: feat, fix, refactor, docs, style, test, chore, perf, build, ci
2. **Scope**: If changes are in 1-2 directories, use as scope e.g. `feat(api):`. If 3+ directories, omit scope.
3. **The WHY**: Understand the purpose, not just the mechanics.
4. **Match style**: Use the recent commits output to match the repo's existing commit message conventions.

Then commit immediately using the `mcp__git-tools__git_commit` MCP tool. Pass the full commit message (including body) as the `message` parameter:

```
type(scope): Short imperative summary (~50 chars)

Explanation of WHAT changed and WHY. Focus on reasoning
and context, not restating the diff. Wrap at 72 chars.
```

## Step 3: Confirm

Use `mcp__git-tools__git_log` with `count: 1` and report the commit hash.

## User Context

$ARGUMENTS

---

After the subagent completes, report the commit result to the user.
