#!/usr/bin/env python3
"""MCP server providing review tools for Claude Code.

Provides tools for code review session management:
- create_review_session: Create a temp directory for review findings
- write_findings: Write reviewer findings to a temp file
- read_all_findings: Read all findings from a session directory
"""

import json
import os
import shutil
import sys
import time


REVIEW_BASE = "/tmp/claude-review"


def _cleanup_stale_sessions():
    """Remove session directories older than 24 hours."""
    if not os.path.isdir(REVIEW_BASE):
        return
    cutoff = time.time() - 86400
    for name in os.listdir(REVIEW_BASE):
        path = os.path.join(REVIEW_BASE, name)
        if os.path.isdir(path):
            try:
                if os.path.getmtime(path) < cutoff:
                    shutil.rmtree(path)
            except OSError:
                pass


def _validate_session_dir(session_dir):
    """Validate session_dir is under REVIEW_BASE. Returns error string or None."""
    real_base = os.path.realpath(REVIEW_BASE)
    real_dir = os.path.realpath(session_dir)
    if not real_dir.startswith(real_base + os.sep) and real_dir != real_base:
        return f"Invalid session_dir: must be under {REVIEW_BASE}"
    return None


def create_review_session(slug=None):
    """Create a new review session directory."""
    _cleanup_stale_sessions()
    if not slug:
        slug = "review"
    hex_suffix = os.urandom(4).hex()
    session_name = f"{slug}-{hex_suffix}"
    session_dir = os.path.join(REVIEW_BASE, session_name)
    os.makedirs(session_dir, exist_ok=True)
    return session_dir


def write_findings(session_dir, focus_area, content):
    """Write findings to a file in the session directory."""
    err = _validate_session_dir(session_dir)
    if err:
        return err
    os.makedirs(session_dir, exist_ok=True)
    file_path = os.path.join(session_dir, f"{focus_area}.md")
    with open(file_path, "w") as fh:
        fh.write(content)
    byte_count = len(content.encode("utf-8"))
    return f"Written {file_path} ({byte_count} bytes)"


def read_all_findings(session_dir):
    """Read all findings from a session directory."""
    err = _validate_session_dir(session_dir)
    if err:
        return err
    if not os.path.isdir(session_dir):
        return f"Session directory not found: {session_dir}"
    parts = []
    for name in sorted(os.listdir(session_dir)):
        if name.endswith(".md"):
            stem = name[:-3]
            file_path = os.path.join(session_dir, name)
            with open(file_path, "r") as fh:
                content = fh.read()
            parts.append(f"=== FINDINGS: {stem} ===")
            parts.append(content)
    if not parts:
        return "No findings files found in session directory"
    return "\n\n".join(parts)


TOOLS = [
    {
        "name": "create_review_session",
        "description": "Create a temp directory for a code review session. Auto-cleans sessions older than 1 hour.",
        "inputSchema": {
            "type": "object",
            "properties": {
                "slug": {
                    "type": "string",
                    "description": "Optional prefix for the session directory name (e.g., plan file basename without .md). Defaults to 'review'.",
                }
            },
        },
    },
    {
        "name": "write_findings",
        "description": "Write code review findings to a temp file in the session directory. Returns a brief confirmation with file path and byte count.",
        "inputSchema": {
            "type": "object",
            "properties": {
                "session_dir": {
                    "type": "string",
                    "description": "The session directory path returned by create_review_session",
                },
                "focus_area": {
                    "type": "string",
                    "description": "The focus area name (e.g., 'correctness', 'security', 'quality', 'plan-compliance')",
                },
                "content": {
                    "type": "string",
                    "description": "The findings content in markdown format",
                },
            },
            "required": ["session_dir", "focus_area", "content"],
        },
    },
    {
        "name": "read_all_findings",
        "description": "Read all findings from a review session directory. Returns concatenated content with === FINDINGS: {focus} === headers.",
        "inputSchema": {
            "type": "object",
            "properties": {
                "session_dir": {
                    "type": "string",
                    "description": "The session directory path returned by create_review_session",
                }
            },
            "required": ["session_dir"],
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
                    "serverInfo": {"name": "review-tools", "version": "1.0.0"},
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

        if name == "create_review_session":
            text = create_review_session(args.get("slug"))
        elif name == "write_findings":
            text = write_findings(args["session_dir"], args["focus_area"], args["content"])
        elif name == "read_all_findings":
            text = read_all_findings(args["session_dir"])
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
