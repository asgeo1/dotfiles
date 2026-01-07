# Submit PR

Use the Task tool to spawn a subagent that handles PR submission.

⚠️ **CRITICAL: Pass the prompt below VERBATIM to the subagent. DO NOT summarize, paraphrase, or truncate. Every detail matters.**

Pass the following prompt:

---

Automate the creation and submission of a GitHub pull request with comprehensive quality checks.

## CRITICAL SAFETY RULES

1. **NEVER force-push** - Use `git push` only, abort if it fails
2. **NEVER create PR from master/main** - Abort immediately if on protected branch
3. **ABORT if working directory is dirty** - All changes must be committed first
4. **ABORT if merge conflicts detected** - Resolve conflicts before PR
5. **ABORT if PR already exists** - Provide link to existing PR instead
6. **NEVER disable linting rules** - No `eslint-disable`, no `as any`, no `rubocop:disable`
7. **NEVER skip fixing issues** - All quality checks must pass before submission

## Step 1: Parse Arguments

Parse the arguments for the following optional flags:

| Flag | Default | Description |
|------|---------|-------------|
| `--draft` | `false` | Create as draft PR |
| `--title "Custom title"` | auto-generated | Override PR title |
| `--base <branch>` | `master` | Target base branch |
| `--dry-run` | `false` | Preview without submitting |
| `--skip-tests` | `false` | Skip test execution (still run formatters/linters) |

**Parsing logic:**
- If `--draft` is present, set `is_draft=true`
- If `--title` is present, capture the quoted string as `custom_title`
- If `--base` is present, capture the next argument as `base_branch`
- If `--dry-run` is present, set `dry_run=true`
- If `--skip-tests` is present, set `skip_tests=true`

<arguments>$ARGUMENTS</arguments>

## Step 2: Pre-flight Checks

### 2a. Verify Not on Protected Branch

Run: `git branch --show-current`

If the current branch is `master` or `main`:
> **ABORT**: Cannot create PR from protected branch `{branch_name}`.
> Please create a feature branch first: `git checkout -b feature/your-feature`

Then STOP - do not proceed further.

### 2b. Check Working Directory Status

Run: `git status --porcelain`

Analyze the output:
- **Untracked files (`??`)** → ABORT with message:
  > **ABORT**: Untracked files detected. Please either:
  > - Stage and commit them: `git add <file> && git commit`
  > - Add them to .gitignore
  > Files: {list files}

- **Unstaged changes (` M`, ` D`)** → ABORT with message:
  > **ABORT**: Unstaged changes detected. Please either:
  > - Stage and commit them: `git add -u && git commit`
  > - Discard them: `git checkout -- <file>`
  > Files: {list files}

- **Staged changes (`M `, `A `, `D `)** → Spawn a nested subagent to handle the commit:
  > **Found staged changes.** Spawning commit subagent to commit them first...

  Use the Task tool with subagent_type="general-purpose" to spawn a commit subagent with this prompt:

  ```
  You are a git commit assistant. Review staged changes and create a commit.

  SAFETY: Only work with staged changes (git diff --cached). Never run git add.

  WORKFLOW:
  1. Run `git diff --cached --stat` - if empty, report "No staged changes" and stop
  2. Run `git diff --cached` for full diff
  3. Run `git log --oneline -10` for commit style
  4. Analyze: change type (feat/fix/refactor/etc), scope, the WHY
  5. Craft commit message (subject ~50 chars + body wrapped at 72)
  6. Execute commit with HEREDOC format
  7. Report: commit hash and one-line summary
  ```

  After commit subagent completes, re-run `git status --porcelain` to verify clean.

- **Empty output** → Working directory is clean, proceed.

### 2c. Verify Branch is Clean

Final verification: `git status --porcelain` must return empty.

If not empty after Step 2b:
> **ABORT**: Failed to clean working directory. Manual intervention required.

## Step 3: Remote & Conflict Checks

### 3a. Check Branch Push Status

Run: `git status -sb`

Look for tracking information:
- If output shows `## branch...origin/branch` with no `[ahead]` → Branch is pushed and up-to-date
- If output shows `## branch...origin/branch [ahead X]` → Need to push X commits
- If output shows `## branch` (no tracking) → Branch not pushed at all

**If branch needs pushing:**

Run: `git push -u origin HEAD`

**CRITICAL**: Do NOT use `--force` or `-f`. If push fails:
> **ABORT**: Push failed. This may indicate:
> - Remote has commits not in local (run `git pull --rebase` first)
> - Permission issues with the remote
> - Network connectivity problems
>
> Error: {push error message}

### 3b. Check for Existing PR

Run: `gh pr list -R {owner}/{repo} --head {current_branch} --state open --json number,title,url`

Extract `owner` and `repo` from `git remote get-url origin`.

If a PR exists for this branch:
> **ABORT**: A pull request already exists for this branch.
>
> **Existing PR:** #{pr_number} - {pr_title}
> **URL:** {pr_url}
>
> To update the existing PR, push additional commits to this branch.

### 3c. Check for Merge Conflicts

Run: `git fetch origin {base_branch}`

Then check if merge is possible: `git merge-tree $(git merge-base HEAD origin/{base_branch}) HEAD origin/{base_branch}`

If the output contains conflict markers (`<<<<<<`, `======`, `>>>>>>`):
> **ABORT**: Merge conflicts detected with `{base_branch}`.
>
> **To resolve:**
> 1. `git fetch origin {base_branch}`
> 2. `git rebase origin/{base_branch}` (or `git merge origin/{base_branch}`)
> 3. Resolve conflicts in each file
> 4. `git add <resolved files>`
> 5. `git rebase --continue` (or `git commit`)
> 6. Re-run `/submit-pr`

## Step 4: Quality Checks

### 4a. Identify Changed Subprojects

First, determine which subprojects have changes relative to the base branch:

Run: `git diff --name-only {base_branch}...HEAD`

Group the changed files by their top-level directory (subproject). For example:
- `api/src/controller.ts` → subproject: `api`
- `web/components/Button.tsx` → subproject: `web`
- `vim/lua/config/keymaps.lua` → subproject: `vim`

Create a list of unique subprojects that need linting.

### 4b. Run Smart-Lint on Each Subproject

⚠️ **CRITICAL: `smart-lint.sh` is a shell script at `~/.claude/hooks/smart-lint.sh` - it is NOT a package.json script or Justfile command!**

For each subproject with changes, run smart-lint from that directory:

```bash
cd {subproject_directory}
~/.claude/hooks/smart-lint.sh
```

The smart-lint script:
- Auto-detects project type (TypeScript, Ruby, Go, Rust, Python, etc.)
- Runs formatters (Prettier, RuboCop, gofmt, cargo fmt, etc.)
- Runs linters (ESLint, RuboCop, golangci-lint, Clippy, etc.)
- Runs type checkers (TypeScript, Sorbet, etc.)

Run smart-lint in each changed subproject sequentially.

**If exit code is 2 (issues found):**

1. **Review the errors** - Read the output carefully
2. **Fix formatting issues** - Run the formatter with --fix or --write flag
3. **Fix linting issues properly**:
   - Do NOT use `as any` or `as unknown as X`
   - Do NOT add `eslint-disable` or `rubocop:disable` comments
   - Do NOT ignore or suppress errors
   - Fix the actual underlying issue
4. **Stage and commit fixes** - Spawn a nested commit subagent with message like "fix: address linting issues"
5. **Re-run smart-lint** - Verify all checks pass

**If you cannot fix an issue, ASK THE USER:**
> I'm stuck on the following issue and need your guidance:
>
> **Error:** {error message}
> **File:** {file path}
> **Line:** {line number}
>
> **What I've tried:** {attempts}
>
> How would you like me to proceed?

**Only proceed when smart-lint exits with code 0.**

### 4c. Run Tests (unless --skip-tests)

If `--skip-tests` is NOT set:

For each subproject with changes, run tests from that directory:

1. **Check for AGENTS.md** in the subproject - it may specify:
   - Exact test commands to use
   - How to run tests efficiently (e.g., through Docker)
   - Parallel test options (e.g., `parallel_rspec`)

2. **If no AGENTS.md**, detect and run tests based on project type:
   - **JavaScript/TypeScript**: `npm test` or `yarn test`
   - **Ruby**: `bundle exec rspec` (check for `--parallel` or `parallel_rspec`)
   - **Go**: `go test ./...`
   - **Rust**: `cargo test`
   - **Python**: `pytest`

```bash
cd {subproject_directory}
# Run test command from AGENTS.md or auto-detected
```

If tests fail:
> **Tests failed.** Review the failures below:
>
> {test output}
>
> **Options:**
> 1. Fix the failing tests and re-run `/submit-pr`
> 2. Run `/submit-pr --skip-tests` if these are known flaky tests (explain why)
>
> How would you like to proceed?

**Do NOT:**
- Comment out failing tests
- Make tests "just pass" in dodgy ways
- Skip tests without user approval

## Step 5: Generate PR Description

### 5a. Gather Commit History

Run: `git log {base_branch}..HEAD --oneline --no-merges`

This shows all commits that will be included in the PR.

### 5b. Get the Full Diff

Run: `git diff {base_branch}...HEAD --stat`

For detailed analysis if needed: `git diff {base_branch}...HEAD`

### 5c. Analyze and Categorize Changes

Review the commits and diff to categorize:

| Category | Description | Indicators |
|----------|-------------|------------|
| **Features** | New functionality | `feat:` commits, new files, new exports |
| **Fixes** | Bug fixes | `fix:` commits, test additions for edge cases |
| **Refactors** | Code improvements | `refactor:` commits, moved/renamed files |
| **Docs** | Documentation | `docs:` commits, README/comment changes |
| **Tests** | Test additions | `test:` commits, spec/test file changes |
| **Chores** | Maintenance | `chore:` commits, dependency updates |

### 5d. Generate Structured Description

Create the PR body with this structure:

```markdown
## Summary

- {Primary change bullet point - what this PR accomplishes}
- {Secondary change bullet point if applicable}
- {Any notable side effects or related changes}

## Changes

### Features
- {Feature 1 description}

### Fixes
- {Fix 1 description}

### Refactors
- {Refactor description}

(Include only sections that have items)

## Test Plan

- [ ] All existing tests pass
- [ ] {Specific test to run or verification step}
- [ ] {Another test/verification}
```

## Step 6: Generate PR Title

### 6a. Check for Custom Title

If `--title` was provided in arguments, use `custom_title` exactly as provided.

### 6b. Auto-Generate Title

If no custom title:

1. Analyze the primary change type from Step 5c
2. Identify the scope (affected area/component)
3. Create a concise description

**Format:** `type(scope): description`

Examples:
- `feat(auth): add OAuth2 login support`
- `fix(api): handle null response from external service`
- `refactor(database): migrate to connection pooling`
- `docs: update README with new installation steps`

**Guidelines:**
- Use imperative mood ("add" not "added")
- Keep under 72 characters
- Be specific about what changed
- Scope is optional for broad changes

## Step 7: Submit PR (unless --dry-run)

### 7a. Dry Run Mode

If `--dry-run` is set, display preview and STOP:

```
═══════════════════════════════════════════════════════════════════
DRY RUN - No PR will be created
═══════════════════════════════════════════════════════════════════

Repository: {owner}/{repo}
Base Branch: {base_branch}
Head Branch: {current_branch}
Draft: {is_draft}

Title:
{generated_title}

Body:
{generated_body}

═══════════════════════════════════════════════════════════════════
Run without --dry-run to create this PR
═══════════════════════════════════════════════════════════════════
```

Then STOP.

### 7b. Extract Repository Info

From `git remote get-url origin`, parse:
- **SSH format**: `git@github.com:owner/repo.git` → owner=`owner`, repo=`repo`
- **HTTPS format**: `https://github.com/owner/repo.git` → owner=`owner`, repo=`repo`

### 7c. Create Pull Request

Run:
```bash
gh pr create -R {owner}/{repo} \
  --title "{generated_or_custom_title}" \
  --base {base_branch} \
  --head {current_branch} \
  --body "{generated_description}" \
  {--draft if is_draft}
```

Capture the returned PR URL and number from the output.

### 7d. Request AI Reviewers

After PR is created, request AI reviewers if available:

Run: `gh pr edit {pr_number} -R {owner}/{repo} --add-reviewer "github-copilot[bot]"`

Note: Reviewer assignment may fail if bots aren't configured on the repo - this is not a blocking error. Log it and continue.

For Claude reviewer, you may need to add a comment mentioning @claude or similar depending on repo configuration.

## Step 8: Report Results

### Success Output

```
═══════════════════════════════════════════════════════════════════
✅ Pull Request Created Successfully!
═══════════════════════════════════════════════════════════════════

🔗 URL: {pr_url}
📝 Title: {pr_title}
🎯 Base: {base_branch} ← {current_branch}
📋 Status: {Draft | Ready for Review}

Summary:
{brief summary of changes from PR body}

AI Reviewers Requested: {list or "None configured"}

Next Steps:
1. Review the PR at the URL above
2. Address any review feedback
3. Merge when approved
═══════════════════════════════════════════════════════════════════
```

### Error Output

If PR creation fails:

```
═══════════════════════════════════════════════════════════════════
❌ Pull Request Creation Failed
═══════════════════════════════════════════════════════════════════

Error: {error message}

Possible causes:
- Branch may not be pushed to remote
- Repository permissions issue
- Network connectivity problem
- GitHub API rate limiting

Please resolve the issue and try again.
═══════════════════════════════════════════════════════════════════
```

---

After the subagent completes, report the PR result to the user.
