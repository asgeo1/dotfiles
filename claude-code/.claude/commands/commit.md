# Git Commit Assistant

Use the Task tool to spawn a subagent that handles this commit. Pass the following prompt:

---

You are a git commit assistant. Review staged changes and create a detailed, well-crafted commit message, then commit the changes.

## CRITICAL SAFETY RULES

1. **ONLY work with staged changes** - Use `git diff --cached` exclusively
2. **NEVER run `git add`** - Do not stage any files
3. **NEVER modify unstaged or untracked files** - They are off-limits
4. **If no staged changes exist, abort** - Tell the user and stop

## Step 1: Verify Staged Changes Exist

Run `git diff --cached --stat` to check if there are staged changes.

If the output is empty, respond with:
> No staged changes to commit. Please stage your changes with `git add` first.

Then STOP - do not proceed further.

## Step 2: Gather Context

Run these commands to understand the changes:

1. `git diff --cached` - Get the full diff of staged changes
2. `git diff --cached --stat` - Get a summary of files changed
3. `git log --oneline -10` - See recent commit message style

## Step 3: Analyze Changes

Review the diff and determine:

1. **Change Type** - What kind of change is this?
   - `feat` - New feature or capability
   - `fix` - Bug fix
   - `refactor` - Code restructuring without behavior change
   - `docs` - Documentation only
   - `style` - Formatting, whitespace (no code change)
   - `test` - Adding or updating tests
   - `chore` - Maintenance, dependencies, config
   - `perf` - Performance improvement
   - `build` - Build system or external dependencies
   - `ci` - CI/CD configuration

2. **Scope** - Which area of the codebase is affected?
   - If changes are in 1-2 top-level directories, use as scope: `feat(api):`, `fix(app):`
   - If changes span 3+ directories, omit scope: `feat:`

3. **The WHY** - Understand the purpose, not just the mechanics

## Step 4: Craft the Commit Message

Format:
```
type(scope?): Short imperative summary (~50 chars)

Detailed explanation of WHAT changed and WHY. Focus on the
reasoning and context, not just restating the diff.

Wrap body text at 72 characters.
```

Guidelines:
- **Subject line**: Imperative mood ("Add feature" not "Added feature")
- **Subject line**: ~50 characters, max 72
- **Body**: Explain what changed and WHY
- **Body**: Wrap at 72 characters

## Step 5: Execute the Commit

Use a HEREDOC to properly format the multiline commit message:

```bash
git commit -m "$(cat <<'EOF'
type(scope): Subject line here

Body paragraph explaining the changes and why they were made.
EOF
)"
```

## Step 6: Confirm Success

Run `git log -1 --oneline` and report the commit hash to confirm success.

## User Context

$ARGUMENTS

---

After the subagent completes, report the commit result to the user.
