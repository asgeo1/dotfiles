# Codex Integration for Claude Code

> **Source:** https://github.com/skills-directory/skill-codex
>
> This is a local copy, version-controlled in this dotfiles repo.

## Purpose

Enable Claude Code to invoke the Codex CLI (`codex exec` and session resumes) for automated code analysis, refactoring, and editing workflows.

## Prerequisites

- `codex` CLI installed and available on `PATH`
- Codex configured with valid credentials and settings
- Confirm installation: `codex --version`

## Usage

### Important: Thinking Tokens
By default, this skill suppresses thinking tokens (stderr output) using `2>/dev/null` to avoid bloating Claude Code's context window. If you want to see the thinking tokens for debugging or insight into Codex's reasoning process, explicitly ask Claude to show them.

### Example Workflow

**User prompt:**
```
Use codex to analyze this repository and suggest improvements for my claude code skill.
```

**Claude Code response:**
Claude will activate the Codex skill and:
1. Ask which model to use (`gpt-5` or `gpt-5-codex`) unless already specified in your prompt.
2. Ask which reasoning effort level (`low`, `medium`, or `high`) unless already specified in your prompt.
3. Select appropriate sandbox mode (defaults to `read-only` for analysis)
4. Run a command like:
```bash
codex exec -m gpt-5-codex \
  --config model_reasoning_effort="high" \
  --sandbox read-only \
  --full-auto \
  --skip-git-repo-check \
  "Analyze this Claude Code skill repository comprehensively..." 2>/dev/null
```

**Result:**
Claude will summarize the Codex analysis output, highlighting key suggestions and asking if you'd like to continue with follow-up actions.

### Detailed Instructions
See `SKILL.md` for complete operational instructions, CLI options, and workflow guidance.
