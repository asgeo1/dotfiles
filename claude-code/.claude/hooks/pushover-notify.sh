#!/bin/bash

# Read hook input from stdin
INPUT=$(cat)

# Check for required env vars
if [ -z "$PUSHOVER_USER_KEY" ] || [ -z "$PUSHOVER_CLAUDE_CODE_API_KEY" ]; then
  echo "Missing PUSHOVER_USER_KEY or PUSHOVER_CLAUDE_CODE_API_KEY" >&2
  exit 0
fi

# Rate limiting configuration
TIMESTAMP_FILE="/tmp/pushover-notify-last-sent"
COOLDOWN_SECONDS="${PUSHOVER_COOLDOWN_SECONDS:-300}"  # 5 minutes default
AFK_THRESHOLD="${PUSHOVER_AFK_SECONDS:-120}"  # 2 minutes default

# Terminal apps that indicate user might be looking at Claude
TERMINAL_APPS="kitty|iTerm2|Terminal|Alacritty|WezTerm|Ghostty"

# Check if a notification was sent recently
was_notified_recently() {
  if [ -f "$TIMESTAMP_FILE" ]; then
    last_sent=$(cat "$TIMESTAMP_FILE")
    now=$(date +%s)
    elapsed=$((now - last_sent))
    [ "$elapsed" -lt "$COOLDOWN_SECONDS" ]
  else
    return 1  # No timestamp file, not recent
  fi
}

# Record that we sent a notification
record_notification() {
  date +%s > "$TIMESTAMP_FILE"
}

# Check if user is AFK (no keyboard/mouse activity)
is_user_afk() {
  # Get idle time in seconds from macOS HID system
  local idle_seconds
  idle_seconds=$(ioreg -c IOHIDSystem 2>/dev/null | awk '/HIDIdleTime/ {print int($NF/1000000000); exit}')

  if [ -z "$idle_seconds" ]; then
    return 1  # Can't determine, assume not AFK
  fi

  [ "$idle_seconds" -ge "$AFK_THRESHOLD" ]
}

# Check if a terminal app is the frontmost application
is_terminal_focused() {
  local frontmost
  frontmost=$(osascript -e 'tell application "System Events" to get name of first application process whose frontmost is true' 2>/dev/null)

  if [ -z "$frontmost" ]; then
    return 1  # Can't determine, assume not focused
  fi

  echo "$frontmost" | grep -qE "^($TERMINAL_APPS)$"
}

# Check if current tmux pane is active (visible and focused)
is_tmux_pane_active() {
  if [ -z "$TMUX" ]; then
    return 0  # Not in tmux, consider "active" (don't block on this check)
  fi

  local pane_active window_active
  pane_active=$(tmux display-message -p '#{pane_active}' 2>/dev/null)
  window_active=$(tmux display-message -p '#{window_active}' 2>/dev/null)

  [ "$pane_active" = "1" ] && [ "$window_active" = "1" ]
}

# Check if current kitty window/tab is focused
is_kitty_window_focused() {
  if [ -z "$KITTY_WINDOW_ID" ]; then
    return 0  # Not in kitty, consider "focused" (don't block on this check)
  fi

  # Use kitty remote control to check window focus state
  local is_focused
  is_focused=$(kitty @ ls 2>/dev/null | jq --arg wid "$KITTY_WINDOW_ID" '
    [.[] | .tabs[] | .windows[] | select(.id == ($wid | tonumber))] |
    if length > 0 then .[0].is_focused else false end
  ' 2>/dev/null)

  [ "$is_focused" = "true" ]
}

# Check if current Ghostty window/tab is focused
# NOTE: Ghostty doesn't have a remote control API yet (as of early 2025)
# When they add one, this function can be updated to check tab/split focus
is_ghostty_window_focused() {
  if [ -z "$GHOSTTY_RESOURCES_DIR" ]; then
    return 0  # Not in Ghostty, consider "focused" (don't block on this check)
  fi

  # TODO: Ghostty scripting API is planned but not yet available
  # See: https://github.com/ghostty-org/ghostty/discussions/2353
  # For now, if Ghostty is frontmost, assume user can see this instance
  return 0
}

# Main visibility check: Is the user actively looking at this Claude instance?
# Returns 0 (true) if user is present and looking, 1 (false) if they need notification
is_user_present() {
  # If user is AFK, they're not present - send notification
  if is_user_afk; then
    return 1
  fi

  # If terminal isn't focused, user is in another app - send notification
  if ! is_terminal_focused; then
    return 1
  fi

  # If in tmux but pane isn't active, user is in different pane - send notification
  if ! is_tmux_pane_active; then
    return 1
  fi

  # If in kitty but window isn't focused, user is in different tab - send notification
  if ! is_kitty_window_focused; then
    return 1
  fi

  # If in Ghostty but window isn't focused, user is in different tab - send notification
  # (Currently a no-op until Ghostty adds scripting API)
  if ! is_ghostty_window_focused; then
    return 1
  fi

  # User is present: not AFK, terminal focused, correct pane/tab visible
  return 0
}

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

# Skip notification if user is actively looking at this Claude instance
# (not AFK, terminal focused, correct tmux pane/kitty tab visible)
if is_user_present; then
  exit 0  # User is watching, no notification needed
fi

# Rate limiting: Skip low-priority notifications if sent recently
# High priority (always send): permission_prompt, Stop
# Low priority (rate limited): idle_prompt
if [ "$HOOK_EVENT" = "Notification" ] && [ "$NOTIFICATION_TYPE" = "idle_prompt" ]; then
  if was_notified_recently; then
    exit 0  # Skip, we already notified recently
  fi
fi

# Send to Pushover
curl -s \
  --form-string "token=$PUSHOVER_CLAUDE_CODE_API_KEY" \
  --form-string "user=$PUSHOVER_USER_KEY" \
  --form-string "title=$TITLE" \
  --form-string "message=$BODY" \
  --form-string "sound=pushover" \
  https://api.pushover.net/1/messages.json > /dev/null

# Record timestamp for rate limiting
record_notification

exit 0
