INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')
[ -z "$COMMAND" ] && exit 0

# Detect `git -C /path` — triggers security prompts. Agent should cd first.
if echo "$COMMAND" | grep -qE '\bgit\s+-C\s+\S'; then
  REAL_CMD=$(echo "$COMMAND" | sed -E 's/git +-C +[^ ]+ */git /')
  TARGET=$(echo "$COMMAND" | sed -E 's/.*git +-C +([^ ]+).*/\1/')
  cat <<EOF
{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"Do not use git -C — it triggers security prompts. Instead, cd to $TARGET first, then run: $REAL_CMD"}}
EOF
  exit 0
fi

# Detect `npm --prefix /path` — triggers security prompts. Agent should cd first.
if echo "$COMMAND" | grep -qE '\bnpm\s+--prefix\s+\S'; then
  REAL_CMD=$(echo "$COMMAND" | sed -E 's/npm +--prefix +[^ ]+ */npm /')
  TARGET=$(echo "$COMMAND" | sed -E 's/.*npm +--prefix +([^ ]+).*/\1/')
  cat <<EOF
{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"Do not use npm --prefix — it triggers security prompts. Instead, cd to $TARGET first, then run: $REAL_CMD"}}
EOF
  exit 0
fi

exit 0
