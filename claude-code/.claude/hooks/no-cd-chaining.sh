INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')
[ -z "$COMMAND" ] && exit 0
if echo "$COMMAND" | grep -qE '^\s*(cd|pushd)\s+\S+\s*(&&|;|\|\|)'; then
  REAL_CMD=$(echo "$COMMAND" | sed -E 's/^\s*(cd|pushd)\s+("[^"]*"|'\''[^'\'']*'\''|[^ &;|]+)\s*(&&|;|\|\|)\s*//')
  cat <<EOF
{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"Do not prefix commands with cd. Run this directly: $REAL_CMD"}}
EOF
  exit 0
fi
exit 0
