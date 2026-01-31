---
name: gemini
description: Use when the user asks to run Gemini CLI (gemini command, gemini resume) or references Google Gemini for code analysis, refactoring, or automated editing
source: Created locally, modeled after skill-codex pattern
---

# Gemini Skill Guide

## Running a Task

1. Select the model if needed (default is usually fine):
   - `-m gemini-3-pro-preview` (default, most capable)
   - `-m gemini-2.5-pro` (next best)
   - `-m gemini-2.5-flash` (faster, cheaper)
   - `-m gemini-2.0-flash` (legacy)

2. Select the approval mode for the task:
   - Default: prompts for approval on each action
   - `--approval-mode auto_edit`: auto-approve file edits only
   - `--approval-mode yolo` or `-y`: auto-approve all actions (use with caution)

3. Assemble the command with appropriate options:
   - `-m, --model <MODEL>` - specify model
   - `--approval-mode <MODE>` - set approval mode (default, auto_edit, yolo)
   - `-y, --yolo` - shortcut for `--approval-mode yolo`
   - `-s, --sandbox` - run in sandbox mode
   - `-c, --checkpointing` - enable file edit checkpoints
   - `--include-directories <DIRS>` - add directories to workspace

4. Run the command and capture the output. The session is automatically saved.

5. **After Gemini completes**, inform the user: "You can resume this Gemini session at any time by saying 'gemini resume' or asking me to continue."

### Quick Reference

| Use case | Key flags |
| --- | --- |
| Basic analysis (default approval) | `gemini "your prompt"` |
| Auto-approve file edits | `gemini --approval-mode auto_edit "your prompt"` |
| Full auto mode | `gemini -y "your prompt"` |
| Specify model | `gemini -m gemini-2.5-flash "your prompt"` |
| Resume latest session | `gemini --resume latest "continue prompt"` |
| Resume specific session | `gemini --resume <id-or-index> "continue prompt"` |
| List sessions | `gemini --list-sessions` |
| With checkpointing | `gemini -c "your prompt"` |

## Session Management

### Starting a Session
```bash
gemini "Your initial prompt here"
```

### Resuming Latest Session
```bash
gemini --resume latest "Continue with your next prompt"
```

This works well for sequential execution (including subagent contexts).

### Resuming with Explicit Session ID (Advanced)
If you need explicit session IDs (e.g., multiple parallel Gemini sessions):
```bash
# List sessions to get index or UUID
gemini --list-sessions

# Resume by index
gemini --resume 1 "Continue..."

# Resume by UUID
gemini --resume a1b2c3d4-e5f6-7890-abcd-ef1234567890 "Continue..."
```

## Following Up

- Use `gemini --resume latest` to continue the most recent session.
- The resumed session automatically uses the same model and settings from the original session.

## Error Handling

- Stop and report failures whenever `gemini --version` or a command exits non-zero; request direction before retrying.
- If Gemini responds with quota errors like "Quota exceeded for quota metric 'Gemini 2.5 Pro Requests'", switch to a different model: `-m gemini-2.5-flash`.
- Before using full auto mode (`-y` or `--approval-mode yolo`), ask the user for permission using AskUserQuestion unless already given.
- When output includes warnings or partial results, summarize them and ask how to adjust using `AskUserQuestion`.

## Context and Memory

- Gemini uses `GEMINI.md` files for project context (similar to `CLAUDE.md`)
- Use `/memory show` in interactive mode to see loaded context
- Gemini can use MCP tools if configured
