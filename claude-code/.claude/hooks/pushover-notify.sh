#!/bin/bash

# Read hook input from stdin
INPUT=$(cat)

# Check for required env vars
if [ -z "$PUSHOVER_USER_KEY" ] || [ -z "$PUSHOVER_CLAUDE_CODE_API_KEY" ]; then
  echo "Missing PUSHOVER_USER_KEY or PUSHOVER_CLAUDE_CODE_API_KEY" >&2
  exit 0
fi

# Extract info using jq
HOOK_EVENT=$(echo "$INPUT" | jq -r '.hook_event_name // "unknown"')
CWD=$(echo "$INPUT" | jq -r '.cwd // ""')
TRANSCRIPT_PATH=$(echo "$INPUT" | jq -r '.transcript_path // ""')
NOTIFICATION_TYPE=$(echo "$INPUT" | jq -r '.notification_type // ""')
MESSAGE=$(echo "$INPUT" | jq -r '.message // ""')

# Get project name from cwd
PROJECT_NAME=$(basename "$CWD")

# Try to get Claude's last message from transcript
LAST_MESSAGE=""
if [ -n "$TRANSCRIPT_PATH" ] && [ -f "$TRANSCRIPT_PATH" ]; then
  LAST_MESSAGE=$(cat "$TRANSCRIPT_PATH" | \
    jq -r 'select(.type == "assistant") | .message.content[]? | select(.type == "text") | .text' | \
    tail -1 | \
    head -c 200)
fi

# Build notification title and message based on hook type
case "$HOOK_EVENT" in
  "Notification")
    case "$NOTIFICATION_TYPE" in
      "permission_prompt")
        TITLE="🔐 $PROJECT_NAME - Permission Required"
        BODY="$MESSAGE"
        ;;
      "idle_prompt")
        TITLE="⏳ $PROJECT_NAME - Waiting for Input"
        BODY="${LAST_MESSAGE:-Claude is waiting for your input}"
        ;;
      *)
        TITLE="📢 $PROJECT_NAME"
        BODY="$MESSAGE"
        ;;
    esac
    ;;
  "Stop")
    TITLE="✅ $PROJECT_NAME - Task Complete"
    if [ -n "$LAST_MESSAGE" ]; then
      BODY="$LAST_MESSAGE"
    else
      BODY="Claude has finished working"
    fi
    ;;
  *)
    TITLE="Claude Code - $PROJECT_NAME"
    BODY="$HOOK_EVENT"
    ;;
esac

# Truncate body if too long
BODY=$(echo "$BODY" | head -c 500)

# Send to Pushover
curl -s \
  --form-string "token=$PUSHOVER_CLAUDE_CODE_API_KEY" \
  --form-string "user=$PUSHOVER_USER_KEY" \
  --form-string "title=$TITLE" \
  --form-string "message=$BODY" \
  --form-string "sound=pushover" \
  https://api.pushover.net/1/messages.json > /dev/null

exit 0
