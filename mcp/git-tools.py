#!/usr/bin/env python3
"""MCP server providing git tools for Claude Code.

Provides whitelisted git tools that avoid permission prompts:
- git_commit: used by /commit command
- git_diff: used by review commands to fetch diffs without security prompts
- git_log: used by review commands for branch history
"""

import json
import subprocess
import sys


def _run(cmd):
    """Run a command and return stdout or error string."""
    try:
        result = subprocess.run(cmd, capture_output=True, text=True)
        if result.returncode == 0:
            return result.stdout
        return f"Error (exit {result.returncode}): {result.stderr.strip()}"
    except Exception as e:
        return f"Error: {e}"


def git_diff(scope, base="master", path=None, name_only=False, stat_only=False):
    """Get git diff output for a given scope."""
    if name_only:
        return _git_diff_name_only(scope, base, path)
    if stat_only:
        return _git_diff_stat_only(scope, base, path)

    sections = []

    if scope == "staged":
        cmd_stat = ["git", "diff", "--cached", "--stat"]
        cmd_diff = ["git", "diff", "--cached"]
        if path:
            cmd_stat += ["--", path]
            cmd_diff += ["--", path]
        sections.append(("STAT", _run(cmd_stat)))
        sections.append(("DIFF", _run(cmd_diff)))

    elif scope == "unstaged":
        cmd_stat = ["git", "diff", "--stat"]
        cmd_diff = ["git", "diff"]
        cmd_untracked = ["git", "ls-files", "--others", "--exclude-standard"]
        if path:
            cmd_stat += ["--", path]
            cmd_diff += ["--", path]
            cmd_untracked += ["--", path]
        sections.append(("STAT", _run(cmd_stat)))
        sections.append(("UNTRACKED", _run(cmd_untracked)))
        sections.append(("DIFF", _run(cmd_diff)))

    elif scope == "all":
        stat_unstaged = _run(["git", "diff", "--stat"] + (["--", path] if path else []))
        stat_staged = _run(["git", "diff", "--cached", "--stat"] + (["--", path] if path else []))
        untracked = _run(["git", "ls-files", "--others", "--exclude-standard"] + (["--", path] if path else []))
        diff_unstaged = _run(["git", "diff"] + (["--", path] if path else []))
        diff_staged = _run(["git", "diff", "--cached"] + (["--", path] if path else []))
        sections.append(("STAT", stat_unstaged + stat_staged))
        sections.append(("UNTRACKED", untracked))
        sections.append(("DIFF", diff_unstaged + diff_staged))

    elif scope == "branch":
        ref = f"{base}...HEAD"
        cmd_stat = ["git", "diff", ref, "--stat"]
        cmd_diff = ["git", "diff", ref]
        cmd_log = ["git", "log", ref, "--oneline"]
        if path:
            cmd_stat += ["--", path]
            cmd_diff += ["--", path]
        sections.append(("LOG", _run(cmd_log)))
        sections.append(("STAT", _run(cmd_stat)))
        sections.append(("DIFF", _run(cmd_diff)))

    else:
        return f"Error: unknown scope '{scope}'. Use: staged, unstaged, all, branch"

    parts = []
    for label, content in sections:
        parts.append(f"=== {label} ===")
        parts.append(content.rstrip())
    return "\n".join(parts)


def _git_diff_stat_only(scope, base="master", path=None):
    """Get just the stat summary of changes."""
    if scope == "staged":
        cmd = ["git", "diff", "--cached", "--stat"]
    elif scope == "unstaged":
        cmd = ["git", "diff", "--stat"]
    elif scope == "all":
        unstaged = _run(["git", "diff", "--stat"] + (["--", path] if path else []))
        staged = _run(["git", "diff", "--cached", "--stat"] + (["--", path] if path else []))
        return (unstaged.rstrip() + "\n" + staged.rstrip()).strip()
    elif scope == "branch":
        cmd = ["git", "diff", f"{base}...HEAD", "--stat"]
    else:
        return f"Error: unknown scope '{scope}'. Use: staged, unstaged, all, branch"

    if path:
        cmd += ["--", path]
    return _run(cmd).rstrip()


def _git_diff_name_only(scope, base="master", path=None):
    """Get just the list of changed file names."""
    if scope == "staged":
        cmd = ["git", "diff", "--cached", "--name-only"]
    elif scope == "unstaged":
        cmd = ["git", "diff", "--name-only"]
    elif scope == "all":
        unstaged = _run(["git", "diff", "--name-only"] + (["--", path] if path else []))
        staged = _run(["git", "diff", "--cached", "--name-only"] + (["--", path] if path else []))
        untracked = _run(["git", "ls-files", "--others", "--exclude-standard"] + (["--", path] if path else []))
        lines = set()
        for output in (unstaged, staged, untracked):
            for line in output.strip().splitlines():
                if line and not line.startswith("Error"):
                    lines.add(line)
        return "\n".join(sorted(lines))
    elif scope == "branch":
        cmd = ["git", "diff", f"{base}...HEAD", "--name-only"]
    else:
        return f"Error: unknown scope '{scope}'. Use: staged, unstaged, all, branch"

    if path:
        cmd += ["--", path]
    return _run(cmd).rstrip()


def _detect_parent_branch():
    """Detect the parent branch of the current feature branch.

    Returns (merge_base_sha, current_branch_name) or (None, current_branch_name)
    if we're on the main branch or can't determine the parent.
    """
    current = _run(["git", "branch", "--show-current"]).strip()
    if current in ("master", "main", ""):
        return None, current

    # Try to find merge-base with common base branches
    for candidate in ("master", "main", "develop"):
        result = subprocess.run(
            ["git", "merge-base", "HEAD", candidate],
            capture_output=True,
            text=True,
        )
        if result.returncode == 0:
            return result.stdout.strip(), current

    return None, current


def git_log(count=10, base=None, scope=None, no_merges=False):
    """Get git log output.

    scope="auto": smart mode — detects feature branch and returns only
    commits since the fork point, plus a few parent branch commits for
    style reference. Falls back to `count` recent commits on master/main.
    """
    merge_flag = ["--no-merges"] if no_merges else []

    if scope == "auto":
        merge_base, current_branch = _detect_parent_branch()
        if merge_base:
            branch_commits = _run(
                ["git", "log", f"{merge_base}..HEAD", "--oneline"] + merge_flag
            ).strip()
            parent_commits = _run(
                ["git", "log", merge_base, "--oneline", "-5"] + merge_flag
            ).strip()
            parts = [
                f"=== BRANCH: {current_branch} ===",
                branch_commits if branch_commits else "(no commits yet)",
                "=== PARENT BRANCH (style reference) ===",
                parent_commits,
            ]
            return "\n".join(parts)
        else:
            return _run(["git", "log", "--oneline", f"-{count}"] + merge_flag).strip()
    elif base:
        cmd = ["git", "log", f"{base}..HEAD", "--oneline"] + merge_flag
    else:
        cmd = ["git", "log", "--oneline", f"-{count}"] + merge_flag
    return _run(cmd).rstrip()


def git_commit(message):
    """Run git commit with the given message."""
    if not message or not message.strip():
        return "Error: commit message cannot be empty"
    try:
        result = subprocess.run(
            ["git", "commit", "-m", message],
            capture_output=True,
            text=True,
        )
        if result.returncode == 0:
            return result.stdout.strip()
        return f"Error (exit {result.returncode}): {result.stderr.strip()}"
    except Exception as e:
        return f"Error: {e}"


TOOLS = [
    {
        "name": "git_diff",
        "description": "Get git diff output. Use this instead of running git diff via Bash to avoid security prompts. Returns structured output with === STAT ===, === DIFF ===, === UNTRACKED ===, and === LOG === sections.",
        "inputSchema": {
            "type": "object",
            "properties": {
                "scope": {
                    "type": "string",
                    "enum": ["staged", "unstaged", "all", "branch"],
                    "description": "What to diff: staged (--cached), unstaged (working tree + untracked), all (staged + unstaged + untracked), branch (vs base branch)",
                },
                "base": {
                    "type": "string",
                    "description": "Base branch for 'branch' scope (default: master)",
                    "default": "master",
                },
                "path": {
                    "type": "string",
                    "description": "Optional file path to restrict the diff to",
                },
                "name_only": {
                    "type": "boolean",
                    "description": "If true, return only changed file names (like git diff --name-only). Default: false.",
                    "default": False,
                },
                "stat_only": {
                    "type": "boolean",
                    "description": "If true, return only the stat summary (like git diff --stat). Default: false.",
                    "default": False,
                },
            },
            "required": ["scope"],
        },
    },
    {
        "name": "git_log",
        "description": "Get git log output (oneline format). Use this instead of running git log via Bash to avoid security prompts. Use scope='auto' for smart branch-aware log.",
        "inputSchema": {
            "type": "object",
            "properties": {
                "count": {
                    "type": "number",
                    "description": "Number of recent commits to show (default: 10). Used as fallback when scope=auto and on master/main.",
                    "default": 10,
                },
                "base": {
                    "type": "string",
                    "description": "If provided, show commits between base...HEAD instead of recent commits",
                },
                "scope": {
                    "type": "string",
                    "enum": ["auto"],
                    "description": "Set to 'auto' for smart detection: on feature branches, shows only commits since fork point from master/main plus parent branch commits for style reference. On master/main, falls back to 'count' recent commits.",
                },
                "no_merges": {
                    "type": "boolean",
                    "description": "If true, exclude merge commits (like git log --no-merges). Default: false.",
                    "default": False,
                },
            },
        },
    },
    {
        "name": "git_commit",
        "description": "Run git commit with a message. Only use this when explicitly asked to commit (e.g., via /commit command). Do NOT use this during normal development work.",
        "inputSchema": {
            "type": "object",
            "properties": {
                "message": {
                    "type": "string",
                    "description": "The full commit message",
                }
            },
            "required": ["message"],
        },
    },
]


def send(data):
    json.dump(data, sys.stdout)
    sys.stdout.write("\n")
    sys.stdout.flush()


def handle(msg):
    method = msg.get("method", "")
    msg_id = msg.get("id")

    if method == "initialize":
        send(
            {
                "jsonrpc": "2.0",
                "id": msg_id,
                "result": {
                    "protocolVersion": "2025-06-18",
                    "capabilities": {"tools": {}},
                    "serverInfo": {"name": "git-tools", "version": "1.0.0"},
                },
            }
        )
    elif method == "notifications/initialized" or method == "initialized":
        pass
    elif method == "tools/list":
        send({"jsonrpc": "2.0", "id": msg_id, "result": {"tools": TOOLS}})
    elif method == "tools/call":
        name = msg["params"]["name"]
        args = msg["params"].get("arguments", {})

        if name == "git_diff":
            text = git_diff(args["scope"], args.get("base", "master"), args.get("path"), args.get("name_only", False), args.get("stat_only", False))
        elif name == "git_log":
            text = git_log(args.get("count", 10), args.get("base"), args.get("scope"), args.get("no_merges", False))
        elif name == "git_commit":
            text = git_commit(args["message"])
        else:
            send(
                {
                    "jsonrpc": "2.0",
                    "id": msg_id,
                    "error": {"code": -32601, "message": f"Unknown tool: {name}"},
                }
            )
            return

        send(
            {
                "jsonrpc": "2.0",
                "id": msg_id,
                "result": {"content": [{"type": "text", "text": text}]},
            }
        )
    elif msg_id is not None:
        send(
            {
                "jsonrpc": "2.0",
                "id": msg_id,
                "error": {"code": -32601, "message": f"Unknown method: {method}"},
            }
        )


def main():
    for line in sys.stdin:
        line = line.strip()
        if not line:
            continue
        try:
            handle(json.loads(line))
        except Exception as e:
            print(f"Error: {e}", file=sys.stderr)


if __name__ == "__main__":
    main()
