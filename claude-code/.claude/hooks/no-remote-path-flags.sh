INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')
[ -z "$COMMAND" ] && exit 0

# All deny messages include this reminder because agents falsely believe cd doesn't persist.
CD_NOTE="The working directory DOES persist between Bash tool calls."

# Detect `git -C /path` — triggers security prompts. Agent should cd first.
if echo "$COMMAND" | grep -qE '\bgit\s+-C\s+\S'; then
  REAL_CMD=$(echo "$COMMAND" | sed -E 's/git +-C +[^ ]+ */git /')
  TARGET=$(echo "$COMMAND" | sed -E 's/.*git +-C +([^ ]+).*/\1/')
  cat <<EOF
{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"Do not use git -C. $CD_NOTE First call: cd $TARGET — Second call: $REAL_CMD"}}
EOF
  exit 0
fi

# Detect `npm --prefix /path` — triggers security prompts. Agent should cd first.
if echo "$COMMAND" | grep -qE '\bnpm\s+--prefix\s+\S'; then
  REAL_CMD=$(echo "$COMMAND" | sed -E 's/npm +--prefix +[^ ]+ */npm /')
  TARGET=$(echo "$COMMAND" | sed -E 's/.*npm +--prefix +([^ ]+).*/\1/')
  cat <<EOF
{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"Do not use npm --prefix. $CD_NOTE First call: cd $TARGET — Second call: $REAL_CMD"}}
EOF
  exit 0
fi

# Detect `docker compose --project-directory /path` — hooks run in cwd so they won't target the correct project.
if echo "$COMMAND" | grep -qE 'docker +compose +--project-directory +\S'; then
  REAL_CMD=$(echo "$COMMAND" | sed -E 's/docker +compose +--project-directory +[^ ]+ */docker compose /')
  TARGET=$(echo "$COMMAND" | sed -E 's/.*docker +compose +--project-directory +([^ ]+).*/\1/')
  cat <<EOF
{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"Do not use docker compose --project-directory. $CD_NOTE First call: cd $TARGET — Second call: $REAL_CMD"}}
EOF
  exit 0
fi

# Detect `bundle --gemfile=/path` or `bundle exec --gemfile=/path` — agent should cd first.
if echo "$COMMAND" | grep -qE '\bbundle\b.*--gemfile=\S'; then
  TARGET=$(echo "$COMMAND" | sed -E 's/.*--gemfile=([^ ]+).*/\1/' | sed -E 's|/Gemfile$||')
  REAL_CMD=$(echo "$COMMAND" | sed -E 's/ *--gemfile=[^ ]+ */ /')
  cat <<EOF
{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"Do not use bundle --gemfile=. $CD_NOTE First call: cd $TARGET — Second call: $REAL_CMD"}}
EOF
  exit 0
fi

# Detect BUNDLE_GEMFILE=/path prefix — same issue as --gemfile=.
if echo "$COMMAND" | grep -qE '^BUNDLE_GEMFILE=\S'; then
  TARGET=$(echo "$COMMAND" | sed -E 's/^BUNDLE_GEMFILE=([^ ]+).*/\1/' | sed -E 's|/Gemfile$||')
  REAL_CMD=$(echo "$COMMAND" | sed -E 's/^BUNDLE_GEMFILE=[^ ]+ *//')
  cat <<EOF
{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"Do not use BUNDLE_GEMFILE= prefix. $CD_NOTE First call: cd $TARGET — Second call: $REAL_CMD"}}
EOF
  exit 0
fi

# Detect `srb tc --dir /path` — agent should cd first.
if echo "$COMMAND" | grep -qE '\bsrb\b.*--dir +\S'; then
  TARGET=$(echo "$COMMAND" | sed -E 's/.*--dir +([^ ]+).*/\1/')
  REAL_CMD=$(echo "$COMMAND" | sed -E 's/ *--dir +[^ ]+ */ /')
  cat <<EOF
{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"Do not use srb tc --dir. $CD_NOTE First call: cd $TARGET — Second call: $REAL_CMD"}}
EOF
  exit 0
fi

# Warn if running bundle install/update inside Docker — remind to also run on host for IDE tools.
if echo "$COMMAND" | grep -qE 'docker +compose +exec +\S+ +bundle +(install|update|add)'; then
  HOST_CMD=$(echo "$COMMAND" | sed -E 's/docker +compose +exec +[^ ]+ +//')
  cat <<EOF
{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"allow","decisionReason":"WARNING: You should ALSO run '$HOST_CMD' on the host (not just in Docker) so IDE tools like Sorbet LSP have access to the gems."}}
EOF
  exit 0
fi

# Warn if running bundle commands on host when docker-compose.yml exists.
# Not a hard block — host installs are sometimes needed for IDE tools —
# but remind the agent it should ALSO run bundle inside the container.
if echo "$COMMAND" | grep -qE '^\s*bundle\s+(install|update|add)'; then
  if [ -f "docker-compose.yml" ] || [ -f "docker-compose.yaml" ]; then
    cat <<EOF
{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"allow","decisionReason":"WARNING: docker-compose.yml detected. Running bundle on the host is OK for IDE tools, but you should ALSO run this inside the container: docker compose exec app $COMMAND"}}
EOF
  fi
fi

exit 0
