INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')
[ -z "$COMMAND" ] && exit 0

# Unwrap bash -c '...' or bash -c "..." if present
INNER="$COMMAND"
if echo "$COMMAND" | grep -qE "^bash +-c +['\"]"; then
  INNER=$(echo "$COMMAND" | sed -E "s/^bash +-c +['\"]//; s/['\"] *$//")
fi

# Detect cd/pushd ANYWHERE in a compound command (chained with && ; ||)
# This catches all workarounds: "cd /path && cmd", "VAR=x && cd /path && cmd",
# "OLDPWD=$PWD && cd /path && cmd", etc.
if echo "$INNER" | grep -qE '(^|&&|;|\|\|)\s*(cd|pushd)\s+\S+\s*(&&|;|\|\|)'; then
  # Extract the cd target
  CD_TARGET=$(echo "$INNER" | grep -oE '(cd|pushd) +[^ &;|]+' | head -1 | sed -E 's/^(cd|pushd) +//')
  # Extract the command after cd (everything after the cd /path && part)
  REAL_CMD=$(echo "$INNER" | sed -E 's/.*(cd|pushd) +[^ &;|]+ *(&&|;|\|\|) *//')
  cat <<EOF
{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"Do not chain cd with other commands. The working directory DOES persist between Bash tool calls. First call: cd $CD_TARGET — Second call: $REAL_CMD"}}
EOF
  exit 0
fi
exit 0
