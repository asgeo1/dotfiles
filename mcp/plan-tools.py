#!/usr/bin/env python3
"""MCP server providing plan file tools for Claude Code.

Provides tools to list and search plan files in ~/.claude/plans/
without triggering security prompts.
"""

import json
import os
import sys


PLANS_DIR = os.path.expanduser("~/.claude/plans")


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
