INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')
[ -z "$COMMAND" ] && exit 0

# Only applies to docker compose commands
echo "$COMMAND" | grep -qE 'docker\s+compose' || exit 0

HAS_PORT_PREFIX=false
echo "$COMMAND" | grep -qE '^[A-Za-z_]+_PORT=[0-9]+\s+docker\s+compose' && HAS_PORT_PREFIX=true

# Scenario 1: Default port, agent added redundant prefix → block, strip prefix
# The prefix triggers Claude Code's security approval prompt for no reason.
if [ "$HAS_PORT_PREFIX" = true ] && [ ! -f ".env.docker" ]; then
  REAL_CMD=$(echo "$COMMAND" | sed -E 's/^[A-Za-z_]+=[0-9]+ //')
  cat <<EOF
{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"Do not prefix docker compose with port env vars — this is the default port and the prefix is unnecessary. Run this directly: $REAL_CMD"}}
EOF
  exit 0
fi

# Scenario 2: Non-default port, agent used prefix → allow (correct behavior)
if [ "$HAS_PORT_PREFIX" = true ] && [ -f ".env.docker" ]; then
  exit 0
fi

# Scenario 3: Non-default port, agent forgot prefix → block, tell them to add it
# Without the prefix, docker compose targets the wrong project's containers.
if [ "$HAS_PORT_PREFIX" = false ] && [ -f ".env.docker" ]; then
  PORT_VAR=$(cat .env.docker | head -1)
  cat <<EOF
{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"This project is running on a non-default port. You must prefix docker compose commands with the port env var. Run this instead: $PORT_VAR $COMMAND"}}
EOF
  exit 0
fi

# Default port, no prefix → fine
exit 0
