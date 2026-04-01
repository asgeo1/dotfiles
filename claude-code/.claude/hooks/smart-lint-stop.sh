#!/usr/bin/env bash
# smart-lint-stop.sh — Stop hook wrapper for monorepo-aware linting
#
# Runs on the Stop hook only (not SubagentStop or PostToolUse).
# Finds all subdirectories with dirty files and runs smart-lint.sh in each.
#
# This solves the monorepo problem: an agent may edit files across api/, app/,
# and engine/ during one session, but the Stop hook only fires once in whatever
# directory the agent last cd'd to. This wrapper ensures all changed subprojects
# get checked.

set +e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SMART_LINT="$SCRIPT_DIR/smart-lint.sh"

# ============================================================================
# MARKER CHECK — skip if no reason to run
# ============================================================================
#
# Two markers, both per-session (PPID):
#   edit marker  — created by PostToolUse when files are edited
#   error marker — created here when checks fail; ensures we re-run next turn
#                  even if no new edits happened (e.g. agent ran bundle install
#                  to fix a dependency error, but didn't edit any files)

# Session ID for marker files. Uses PPID (the Claude Code process PID) which is
# unique per instance and consistent across all hooks in one session.
# CLAUDE_LINT_SESSION can override this for testing, since bash's $PPID is
# read-only and can't be faked with env: CLAUDE_LINT_SESSION=test123
_SESSION_ID="${CLAUDE_LINT_SESSION:-${PPID}}"
_EDIT_MARKER="/tmp/.claude-lint-edits-${_SESSION_ID}"
_ERROR_MARKER="/tmp/.claude-lint-error-${_SESSION_ID}"

# Manual run (terminal) always proceeds; hook run checks markers
if [[ ! -t 0 ]]; then
    if [[ ! -f "$_EDIT_MARKER" ]] && [[ ! -f "$_ERROR_MARKER" ]]; then
        exit 0
    fi
fi

# Clean up the edit marker (consumed). Error marker is handled after checks.
rm -f "$_EDIT_MARKER"

# ============================================================================
# FIND GIT ROOT AND CHANGED SUBDIRECTORIES
# ============================================================================

GIT_ROOT=$(git rev-parse --show-toplevel 2>/dev/null)
if [[ -z "$GIT_ROOT" ]]; then
    # Not in a git repo — just run smart-lint.sh in cwd
    bash "$SMART_LINT" --no-marker-check
    exit $?
fi

# Get unique top-level directories with changes (staged, unstaged, or untracked)
# e.g. "api/app/models/user.rb" → "api"
# Files at repo root (no slash) get "." as their directory
CHANGED_DIRS=$(
    cd "$GIT_ROOT" &&
    git status --porcelain 2>/dev/null |
    cut -c4- |
    sed 's| -> ||' |
    sed -E 's|/.*||' |
    sort -u
)

if [[ -z "$CHANGED_DIRS" ]]; then
    if [[ -t 0 ]]; then
        echo "No git changes detected. Running in all project subdirectories anyway." >&2
        # Find all subdirectories
        CHANGED_DIRS=$(
            cd "$GIT_ROOT" &&
            for d in */; do
                echo "${d%/}"
            done
        )
    elif [[ -f "$_ERROR_MARKER" ]]; then
        # No new changes, but previous run failed — re-run in the directories
        # that failed last time (stored in the error marker)
        CHANGED_DIRS=$(cat "$_ERROR_MARKER")
    else
        exit 0
    fi
fi

# ============================================================================
# RUN SMART-LINT IN EACH CHANGED SUBPROJECT
# ============================================================================

EXIT_CODE=0
FAILED_DIRS=""

# Run smart-lint.sh in each changed directory.
# smart-lint.sh handles project detection internally — if a directory isn't a
# recognized project type, it exits cleanly. No need to pre-filter here.
for dir in $CHANGED_DIRS; do
    if [[ "$dir" == "." ]]; then
        FULL_PATH="$GIT_ROOT"
    else
        FULL_PATH="$GIT_ROOT/$dir"
    fi

    # Skip if not a directory (could be a file at repo root)
    [[ ! -d "$FULL_PATH" ]] && continue

    (
        cd "$FULL_PATH" || exit 1
        bash "$SMART_LINT" --no-marker-check
    )
    local_exit=$?
    if [[ $local_exit -ne 0 ]]; then
        EXIT_CODE=$local_exit
        FAILED_DIRS="${FAILED_DIRS}${dir}\n"
    fi
done

# ============================================================================
# ERROR MARKER — persist failure so next turn re-runs even without new edits
# ============================================================================

if [[ $EXIT_CODE -ne 0 ]]; then
    # Write failed directories so we know what to re-check
    printf "$FAILED_DIRS" > "$_ERROR_MARKER"
else
    # All passed — clear any previous error marker
    rm -f "$_ERROR_MARKER"
fi

exit $EXIT_CODE
