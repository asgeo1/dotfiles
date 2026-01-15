# Gemini Integration for Claude Code

> **Source:** Created locally, modeled after the [skill-codex](https://github.com/skills-directory/skill-codex) pattern
>
> This is a local skill, version-controlled in this dotfiles repo.

## Purpose

Enable Claude Code to invoke the Gemini CLI for automated code analysis, refactoring, and editing workflows.

## Prerequisites

- `gemini` CLI installed via Homebrew: `brew install gemini`
- Gemini configured with valid credentials
- Confirm installation: `gemini --version`

## Usage

### Example Workflow

**User prompt:**
```
Use gemini to analyze this repository and suggest improvements.
```

**Claude Code response:**
Claude will activate the Gemini skill and:
1. Run a command like:
```bash
gemini "Analyze this repository comprehensively..."
```
2. Capture the session ID for potential follow-up
3. Summarize the analysis output
4. Ask if you'd like to continue with follow-up actions

### Session Management

Gemini automatically saves sessions. To resume:
```bash
# List available sessions
gemini --list-sessions

# Resume by index (preferred - explicit)
gemini --resume 1 "Continue with..."

# Resume latest (simple but less safe)
gemini --resume latest "Continue..."
```

### Detailed Instructions

See `SKILL.md` for complete operational instructions, CLI options, and workflow guidance.
