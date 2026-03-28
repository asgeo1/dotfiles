INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')
[ -z "$COMMAND" ] && exit 0
if echo "$COMMAND" | grep -qE '^\s*(cd|pushd)\s+\S+\s*(&&|;|\|\|)'; then
  CD_TARGET=$(echo "$COMMAND" | sed -E 's/^(cd|pushd) +([^ &;|]+).*/\2/')
  REAL_CMD=$(echo "$COMMAND" | sed -E 's/^(cd|pushd) +[^ &;|]+ *(&&|;|\|\|) *//')
  cat <<EOF
{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"Do not chain cd with other commands. The working directory DOES persist between Bash tool calls. First call: cd $CD_TARGET — Second call: $REAL_CMD"}}
EOF
  exit 0
fi
exit 0
