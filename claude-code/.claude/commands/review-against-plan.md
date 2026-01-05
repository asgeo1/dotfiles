# Review Against Plan

Review uncommitted changes against the current implementation plan to catch incomplete implementations, cruft, and quality issues before committing.

Use the Task tool to spawn a subagent that handles this review. **You should already know what plan you're working on** - include its path in the prompt below, or pass it via $ARGUMENTS.

Pass the following prompt (replace `[PLAN_PATH]` with the actual plan file path):

---

You are a code review assistant. Your job is to review uncommitted changes against an implementation plan and report issues.

## CRITICAL SAFETY RULES

1. **READ-ONLY ONLY** - Never modify files, never stage, never commit
2. **REPORT ONLY** - Findings are recommendations, the user decides what to do
3. **NO PLAN = ABORT** - If you cannot locate the plan, stop and ask for clarification

## Step 1: Locate the Plan

Plan file path: `[PLAN_PATH]`

User-provided arguments: $ARGUMENTS

If a path is provided in arguments, use that. Otherwise use the path specified above.

If no plan path is available, ABORT with:
> Cannot review without a plan. Please specify a plan file path or re-establish context with the current plan.

Read the plan file and understand:
- What features/changes are being implemented
- What files should be affected
- What the expected outcomes are

## Step 2: Gather Change Context

Run these commands to understand the current state:

```bash
# Current working state
git status --porcelain

# Staged changes (primary focus)
git diff --cached --stat

# Unstaged changes
git diff --stat

# Untracked files
git ls-files --others --exclude-standard

# Branch context - commits on this branch vs master
git log master..HEAD --oneline 2>/dev/null || git log main..HEAD --oneline

# All files changed in this branch
git diff master..HEAD --name-only 2>/dev/null || git diff main..HEAD --name-only
```

Categorize files into:
- **Staged**: Ready to commit (primary review focus)
- **Unstaged**: Modified but not staged
- **Untracked**: New files not yet tracked
- **Branch commits**: Already committed in this branch (context only)

## Step 3: Identify Subprojects & Run Smart-Lint

From all changed files (staged + unstaged + untracked), identify unique top-level directories (subprojects).

For EACH subproject with changes:
1. Navigate to the subproject directory
2. Run: `~/.claude/hooks/smart-lint.sh`
3. Capture the output and exit code

**Important**: Smart-lint failures are reported but do NOT abort the review. Continue with all other checks and include lint issues in the final report.

## Step 4: Plan-to-Implementation Mapping

For each item/feature in the plan:

1. **Identify expected files** - What files should implement this feature?
2. **Check implementation status**:
   - Is it in staged changes?
   - Is it in unstaged changes?
   - Was it done in a previous commit on this branch?
3. **Read the actual files** to verify the implementation is complete
4. **Flag issues**:
   - `Missing` - No implementation found
   - `Partial` - Started but incomplete (missing error handling, edge cases, etc.)
   - `Unexpected location` - Implemented but in wrong file/place

## Step 5: Cruft Detection

Scan changed files for:

1. **Multiple implementations** - Same feature implemented in different ways/files
2. **Dead code** - Functions, classes, or variables not used by the implementation
3. **Debug artifacts**:
   - `console.log`, `console.debug`
   - `binding.pry`, `byebug`, `debugger`
   - `dbg!`, `println!` (in Rust)
   - `print()`, `pp` (debugging prints)
   - Comments like `// TODO: remove`, `// FIXME`, `// DEBUG`
4. **Failed attempts**:
   - Large blocks of commented-out code
   - Files with `_old`, `_backup`, `_v2`, `_new` suffixes
   - Duplicate implementations with one commented out
5. **Scope creep** - Changes to files not mentioned or implied by the plan
6. **Unintentional files** - IDE configs, OS files, local settings

## Step 6: Quality & Best Practices Check

Check changed files against developer guidelines:

1. **Forbidden patterns** (BLOCKING):
   - TypeScript: `as any`, `as unknown as`
   - Lint disables: `eslint-disable`, `rubocop:disable`, `@ts-ignore`

2. **TODOs in final code** - Flag any `TODO`, `FIXME`, `HACK` comments (unless explicitly in plan)

3. **Naming quality** - Flag generic names like `id`, `data`, `result`, `temp`, `x`

4. **Code structure**:
   - Deep nesting (4+ levels) - suggest early returns
   - Commented-out code alongside new code - should be deleted

5. **Old code not deleted** - If replacing functionality, check old implementation is removed

## Step 7: Test Coverage Check

For each significantly changed file:

1. **Identify test location** based on language:
   - Ruby: `spec/**/*_spec.rb` (mirrors `app/` or `lib/` structure)
   - Rust: `#[test]` in same file or `tests/` directory
   - TypeScript/JS: `*.test.ts`, `*.spec.ts`, `__tests__/`
   - Python: `test_*.py`, `*_test.py`, `tests/`

2. **Check for corresponding tests**:
   - New file with logic? Should have tests
   - Modified existing logic? Tests should be updated
   - Bug fix? Should have regression test

3. **Flag missing tests** for files that clearly need them

## Step 8: Generate Report

Output an **actionable summary** - only show issues, skip passing checks.

```markdown
# Review Against Plan: [Plan Title]

## Issues Found

### Plan Coverage Gaps
(Only if incomplete/missing items exist)
| Plan Item | Status | Issue |
|-----------|--------|-------|
| [Feature name] | Partial | [Specific issue with file:line] |
| [Feature name] | Missing | No implementation found |

### Smart-Lint Failures
(Only if lint issues exist)
- `[subproject]/`: N issues
  - [Specific issue 1]
  - [Specific issue 2]

### Quality Issues
(Only if issues found)
- [Issue type] in `[file:line]`: [description]

### Cruft Detected
(Only if cruft found)
| Type | Location | Action Needed |
|------|----------|---------------|
| [Type] | `[file:line]` | [What to do] |

### Out-of-Scope Changes
(Only if unexpected changes found)
- `[file]` - [Why it's unexpected, verify if intentional]

## Recommendations
1. [Most critical actionable fix]
2. [Next priority fix]
...

## Summary
- Plan items: X complete, Y partial, Z missing
- Quality issues: N found
- Ready to commit: YES / NO (with reason if NO)
```

**If everything passes**, output a brief summary:
```markdown
# Review Against Plan: [Plan Title]

All checks passed. Implementation appears complete and ready to commit.

- Plan items: X/X complete
- Smart-lint: Passed in all subprojects
- No quality issues or cruft detected
```

---

After the subagent completes, report the review results to the user. If issues were found, ask if they want help fixing any of them.

