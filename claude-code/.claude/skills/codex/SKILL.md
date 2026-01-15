---
name: codex
description: Use when the user asks to run Codex CLI (codex exec, codex resume) or references OpenAI Codex for code analysis, refactoring, or automated editing
source: https://github.com/skills-directory/skill-codex (modified for explicit session IDs)
---

# Codex Skill Guide

## Running a Task

1. Select the sandbox mode required for the task; default to `--sandbox read-only` unless edits or network access are necessary.

2. Assemble the command with the appropriate options:
   - `-m, --model <MODEL>` - specify model (optional, uses default if omitted)
   - `--config model_reasoning_effort="<xhigh|high|medium|low>"` - reasoning effort (optional)
   - `--sandbox <read-only|workspace-write|danger-full-access>` - sandbox mode
   - `--full-auto` - auto-approve within sandbox
   - `-C, --cd <DIR>` - working directory
   - `--skip-git-repo-check` - always use this flag
   - `--json` - output JSONL (use when you need to capture session ID)

3. **IMPORTANT**: By default, append `2>/dev/null` to suppress thinking tokens (stderr). Only show stderr if debugging is needed.

4. Run the command, capture stdout/stderr (filtered as appropriate), and summarize the outcome for the user.

5. **After Codex completes**, inform the user: "You can resume this Codex session at any time by saying 'codex resume' or asking me to continue."

### Quick Reference

| Use case | Key flags |
| --- | --- |
| Read-only review/analysis | `--sandbox read-only --skip-git-repo-check 2>/dev/null` |
| Apply local edits | `--sandbox workspace-write --full-auto --skip-git-repo-check 2>/dev/null` |
| Full access | `--sandbox danger-full-access --full-auto --skip-git-repo-check 2>/dev/null` |
| Resume latest session | `echo "prompt" \| codex exec --skip-git-repo-check resume --last 2>/dev/null` |

## Session Management

### Resuming Latest Session

```bash
echo "continue prompt" | codex exec --skip-git-repo-check resume --last 2>/dev/null
```

This works well for sequential execution (including subagent contexts).

### Resuming with Explicit Session ID (Advanced)

If you need explicit session IDs (e.g., multiple parallel Codex sessions):

```bash
# Get the most recent session ID from filesystem
SESSION_ID=$(ls -t ~/.codex/sessions/*/*/*/*.jsonl | head -1 | grep -oE '[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}')

# Resume with explicit ID
codex exec --skip-git-repo-check resume "$SESSION_ID" "continue prompt" 2>/dev/null
```

## Following Up

- After every `codex` command, capture or note the session ID for potential resumption.
- When resuming, prefer explicit session IDs over `--last` for reliability.
- The resumed session automatically uses the same model, reasoning effort, and sandbox mode from the original session.
- Restate the chosen settings when proposing follow-up actions.

## Error Handling

- Stop and report failures whenever `codex --version` or a `codex exec` command exits non-zero; request direction before retrying.
- Before using high-impact flags (`--full-auto`, `--sandbox danger-full-access`), ask the user for permission using AskUserQuestion unless already given.
- When output includes warnings or partial results, summarize them and ask how to adjust using `AskUserQuestion`.
