INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')
[ -z "$COMMAND" ] && exit 0

# Detect backslash before shell operators (\;, \|, \&, \<, \>)
# These trigger Claude Code's "backslash before a shell operator" security prompt
if echo "$COMMAND" | grep -qE '\\[;|&<>]'; then
  # Build a helpful suggestion based on what we detect
  SUGGESTION=""

  # \; in find -exec → suggest + or grep -rl
  if echo "$COMMAND" | grep -qE '\\;'; then
    SUGGESTION="Replace find -exec ... \\\\; with: (1) grep -rl instead of find -exec grep, (2) find -exec ... {} + instead of \\\\;, or (3) find ... | xargs ..."
  fi

  # \| in grep (BRE alternation) → suggest grep -E
  if echo "$COMMAND" | grep -qE '\\[|]'; then
    SUGGESTION="Use grep -E (extended regex) so alternation is | not \\\\|. Example: grep -E \"foo|bar\" instead of grep \"foo\\\\|bar\""
  fi

  if [ -z "$SUGGESTION" ]; then
    SUGGESTION="Restructure the command to avoid backslashes before shell operators (;|&<>). These trigger a security prompt."
  fi

  cat <<EOF
{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"Command contains a backslash before a shell operator (;, |, &, <, >) which triggers a security prompt. $SUGGESTION"}}
EOF
  exit 0
fi
exit 0
