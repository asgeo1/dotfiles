#!/usr/bin/env python3
"""MCP server providing plan file tools for Claude Code.

Provides tools to list and search plan files in ~/.claude/plans/
without triggering security prompts.
"""

import json
import os
import sys


PLANS_DIR = os.path.expanduser("~/.claude/plans")


def validate_plan_path(file_path):
    """Validate and resolve a plan file path. Returns (resolved_path, error_msg)."""
    expanded = os.path.expanduser(file_path)
    resolved = os.path.realpath(expanded)
    plans_real = os.path.realpath(PLANS_DIR)
    if not resolved.startswith(plans_real + os.sep) and resolved != plans_real:
        return None, f"Path must be under ~/.claude/plans/, got: {file_path}"
    if not resolved.endswith(".md"):
        return None, f"Only .md files are supported, got: {file_path}"
    return resolved, None


def list_recent_plans(count=5):
    """List the most recently modified plan files with their titles."""
    if not os.path.isdir(PLANS_DIR):
        return "No plans directory found at ~/.claude/plans/"

    files = []
    for f in os.listdir(PLANS_DIR):
        if f.endswith(".md"):
            full_path = os.path.join(PLANS_DIR, f)
            mtime = os.path.getmtime(full_path)
            files.append((mtime, full_path))

    files.sort(reverse=True)
    files = files[:count]

    if not files:
        return "No plan files found in ~/.claude/plans/"

    results = []
    for _, path in files:
        with open(path, "r") as fh:
            first_line = fh.readline().strip()
        title = first_line.lstrip("#").strip() or "(no title)"
        results.append(f"- **{title}** → `{path}`")

    return "\n".join(results)


def find_plan_by_title(title):
    """Find a plan file by searching for a title string."""
    if not os.path.isdir(PLANS_DIR):
        return "No plans directory found at ~/.claude/plans/"

    for f in os.listdir(PLANS_DIR):
        if f.endswith(".md"):
            full_path = os.path.join(PLANS_DIR, f)
            with open(full_path, "r") as fh:
                first_line = fh.readline().strip()
            if title.lower() in first_line.lower():
                return full_path

    return f"No plan file found with title matching: {title}"


def read_plan(file_path, offset=0, limit=0):
    """Read a plan file's contents."""
    resolved, err = validate_plan_path(file_path)
    if err:
        return err
    if not os.path.isfile(resolved):
        return f"File not found: {file_path}"
    with open(resolved, "r") as fh:
        lines = fh.readlines()
    if offset > 0:
        lines = lines[offset:]
    if limit > 0:
        lines = lines[:limit]
    return "".join(lines)


def write_plan(file_path, content):
    """Write content to a plan file."""
    resolved, err = validate_plan_path(file_path)
    if err:
        return err
    os.makedirs(os.path.dirname(resolved), exist_ok=True)
    with open(resolved, "w") as fh:
        fh.write(content)
    return f"Written to {file_path}"


TOOLS = [
    {
        "name": "list_recent_plans",
        "description": "List the most recently modified plan files from ~/.claude/plans/ with their titles. Use this to find the current plan when no plan path is specified.",
        "inputSchema": {
            "type": "object",
            "properties": {
                "count": {
                    "type": "number",
                    "description": "Number of recent plans to return (default: 5)",
                    "default": 5,
                }
            },
        },
    },
    {
        "name": "find_plan_by_title",
        "description": "Find a plan file by searching for a title string in ~/.claude/plans/. Returns the full path of the first matching plan file.",
        "inputSchema": {
            "type": "object",
            "properties": {
                "title": {
                    "type": "string",
                    "description": "Title text to search for (case-insensitive partial match)",
                }
            },
            "required": ["title"],
        },
    },
    {
        "name": "read_plan",
        "description": "Read the contents of a plan file from ~/.claude/plans/. Accepts ~/... or absolute paths. Use this instead of the Read tool to avoid permission prompts.",
        "inputSchema": {
            "type": "object",
            "properties": {
                "file_path": {
                    "type": "string",
                    "description": "Path to the plan file (e.g., ~/.claude/plans/my-plan.md or /Users/.../plans/my-plan.md)",
                },
                "offset": {
                    "type": "number",
                    "description": "Line offset to start reading from (0-based, default: 0)",
                    "default": 0,
                },
                "limit": {
                    "type": "number",
                    "description": "Maximum number of lines to return (0 = all, default: 0)",
                    "default": 0,
                },
            },
            "required": ["file_path"],
        },
    },
    {
        "name": "write_plan",
        "description": "Write content to a plan file in ~/.claude/plans/. Creates the file if it doesn't exist. Use this instead of the Write tool to avoid permission prompts.",
        "inputSchema": {
            "type": "object",
            "properties": {
                "file_path": {
                    "type": "string",
                    "description": "Path to the plan file (e.g., ~/.claude/plans/my-plan.md)",
                },
                "content": {
                    "type": "string",
                    "description": "The content to write to the plan file",
                },
            },
            "required": ["file_path", "content"],
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
                    "serverInfo": {"name": "plan-tools", "version": "1.0.0"},
                },
            }
        )
    elif method == "notifications/initialized" or method == "initialized":
        pass  # notification, no response
    elif method == "tools/list":
        send({"jsonrpc": "2.0", "id": msg_id, "result": {"tools": TOOLS}})
    elif method == "tools/call":
        name = msg["params"]["name"]
        args = msg["params"].get("arguments", {})

        if name == "list_recent_plans":
            text = list_recent_plans(args.get("count", 5))
        elif name == "find_plan_by_title":
            text = find_plan_by_title(args["title"])
        elif name == "read_plan":
            text = read_plan(args["file_path"], args.get("offset", 0), args.get("limit", 0))
        elif name == "write_plan":
            text = write_plan(args["file_path"], args["content"])
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
