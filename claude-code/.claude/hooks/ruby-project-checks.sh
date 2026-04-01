#!/usr/bin/env bash
# ruby-project-checks.sh — Ruby/Rails project-specific CI checks
#
# SYNOPSIS
#   ruby-project-checks.sh
#
# DESCRIPTION
#   Runs the same checks as the project's GitHub CI workflow, minus RuboCop and
#   Sorbet (which smart-lint.sh already handles) and tests (too slow for a hook).
#
#   Uses feature detection — only runs a check if its bin/ script exists.
#   Lives in the dotfiles hooks directory (global), not per-repo.
#
# DOCKER SUPPORT
#   Some checks need to run inside Docker. If the project was started on a
#   non-default port (via bin/start_services), the script reads .env.docker
#   to pass the correct port env var to docker compose commands.
#
# EXIT CODES
#   0 - All checks passed
#   1 - One or more checks failed

set +e

# ============================================================================
# COLOR DEFINITIONS
# ============================================================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# ============================================================================
# TRACKING
# ============================================================================

declare -i ERROR_COUNT=0
declare -a SUMMARY=()
declare -a TIMINGS=()

# Per-check timing
_ck_label=""
_ck_start=0

ck() {
    # If a previous check was being timed, capture it
    if [[ -n "$_ck_label" && $_ck_start -gt 0 ]]; then
        local elapsed=$(( $(date +%s) - _ck_start ))
        TIMINGS+=("$_ck_label:${elapsed}s")
    fi
    _ck_label="$1"
    _ck_start=$(date +%s)
}

# Finalize the last ck() timer
finalize_timing() {
    if [[ -n "$_ck_label" && $_ck_start -gt 0 ]]; then
        local elapsed=$(( $(date +%s) - _ck_start ))
        TIMINGS+=("$_ck_label:${elapsed}s")
        _ck_label=""
        _ck_start=0
    fi
}

add_result() {
    local level="$1"
    local message="$2"
    if [[ "$level" == "error" ]]; then
        ERROR_COUNT+=1
        SUMMARY+=("${RED}❌${NC} $message")
    elif [[ "$level" == "warn" ]]; then
        SUMMARY+=("${YELLOW}⚠️${NC}  $message")
    elif [[ "$level" == "skip" ]]; then
        SUMMARY+=("${YELLOW}⏭️${NC}  $message")
    else
        SUMMARY+=("${GREEN}✅${NC} $message")
    fi
}

print_summary() {
    echo -e "\n${BLUE}═══ Ruby Project Checks Summary ═══${NC}" >&2
    for item in "${SUMMARY[@]}"; do
        echo -e "  $item" >&2
    done
    if [[ ${#TIMINGS[@]} -gt 0 ]]; then
        local total=0
        for t in "${TIMINGS[@]}"; do
            local v="${t##*:}"
            total=$(( total + ${v%s} ))
        done
        local timing_line
        timing_line=$(printf '%s | ' "${TIMINGS[@]}")
        echo -e "\n⏱  ${timing_line% | } | total:${total}s" >&2
    fi
    if [[ $ERROR_COUNT -gt 0 ]]; then
        echo -e "\n${RED}$ERROR_COUNT check(s) failed!${NC}" >&2
    else
        echo -e "\n${GREEN}All checks passed!${NC}" >&2
    fi
}

# ============================================================================
# DOCKER HELPERS
# ============================================================================

# Wrapper that sources .env.docker if present, so docker compose targets
# the correct project when multiple checkouts run on different ports.
docker_compose() {
    if [[ -f ".env.docker" ]]; then
        env $(cat .env.docker) docker compose "$@"
    else
        docker compose "$@"
    fi
}

DOCKER_AVAILABLE=false

check_docker() {
    if docker_compose ps --status running 2>/dev/null | grep -q "app"; then
        DOCKER_AVAILABLE=true
    else
        DOCKER_AVAILABLE=false
    fi
}

docker_exec() {
    docker_compose exec -T app "$@"
}

# Like docker_exec but with an extra -e flag for an env override
# Usage: docker_exec_with_env "KEY=VALUE" command args...
docker_exec_with_env() {
    local env_override="$1"
    shift
    docker_compose exec -T -e "$env_override" app "$@"
}

# Auto-detect the tapioca database env override from official config files.
# Returns a KEY=VALUE string (e.g. "GC_DATABASE=guitarcanvas_tapioca") or empty.
#
# Detection strategy:
#   1. Env var name: parse config/boot.rb for ENV["XXX_DATABASE"] (PostgreSQL projects)
#      or config/database.yml for ENV.fetch("XXX_DATABASE") (MySQL projects)
#   2. Tapioca DB name: parse docker-compose.yml for DATABASE_URL, extract dev db name,
#      replace _development with _tapioca
#   3. Fallback: parse bin/check_tapioca_dsl for the -e KEY=VALUE pair
detect_tapioca_db_override() {
    local db_env_var=""
    local tapioca_db_name=""

    # --- Step 1: Detect the XXX_DATABASE env var ---

    # Try config/boot.rb first (PostgreSQL projects)
    if [[ -f "config/boot.rb" ]]; then
        db_env_var=$(grep -oE 'ENV\["[A-Z_]+_DATABASE"\]' config/boot.rb | head -1 | sed 's/ENV\["//;s/"\]//')
    fi

    # Fallback: try config/database.yml (MySQL projects like FieldFolio)
    if [[ -z "$db_env_var" && -f "config/database.yml" ]]; then
        db_env_var=$(grep -oE 'ENV\.fetch\("[A-Z_]+_DATABASE"\)' config/database.yml | head -1 | sed 's/ENV\.fetch("//;s/")//')
    fi

    # --- Step 2: Derive the tapioca database name ---

    # Try docker-compose.yml — parse DATABASE_URL to get dev db name, replace _development with _tapioca
    local compose_file=""
    for candidate in docker-compose.yml docker-compose.yaml ../docker-compose.yml ../docker-compose.yaml; do
        if [[ -f "$candidate" ]]; then
            compose_file="$candidate"
            break
        fi
    done

    if [[ -n "$compose_file" ]]; then
        local db_url
        db_url=$(grep -E 'DATABASE_URL[=:]' "$compose_file" | grep -oE 'postgres://[^ "]+' | head -1)
        if [[ -n "$db_url" ]]; then
            # Extract db name from URL path: postgres://host:port/DB_NAME → DB_NAME
            local dev_db_name
            dev_db_name=$(echo "$db_url" | sed 's|.*/||')
            if [[ -n "$dev_db_name" ]]; then
                tapioca_db_name="${dev_db_name%_development}_tapioca"
            fi
        fi
    fi

    # --- Step 3: If we have both, return the override ---
    if [[ -n "$db_env_var" && -n "$tapioca_db_name" ]]; then
        echo "${db_env_var}=${tapioca_db_name}"
        return 0
    fi

    # --- Step 4: Fallback — parse bin/check_tapioca_dsl for the -e KEY=VALUE pair ---
    if [[ -f "bin/check_tapioca_dsl" ]]; then
        local override
        override=$(grep -oE '\-e [A-Z_]+=[^ ]+' bin/check_tapioca_dsl | head -1 | sed 's/^-e //')
        if [[ -n "$override" ]]; then
            echo "$override"
            return 0
        fi
    fi

    return 1
}

# Progress output — shows which check is currently running
run_msg() {
    echo -e "  ${BLUE}→${NC} $1..." >&2
}

# ============================================================================
# GUARD: Only run in a Ruby/Rails project
# ============================================================================

if [[ ! -f "Gemfile" ]]; then
    echo "Not a Ruby project (no Gemfile found), skipping." >&2
    exit 0
fi

# ============================================================================
# PHASE 1: Host-only checks (fast, no Docker needed)
# ============================================================================

echo -e "${BLUE}─── Phase 1: Host checks ───${NC}" >&2

ck "host-checks"

# check_unwanted_executables
if [[ -x "bin/check_unwanted_executables" ]]; then
    run_msg "check_unwanted_executables"
    if bin/check_unwanted_executables >/dev/null 2>&1; then
        add_result "success" "check_unwanted_executables"
    else
        bin/check_unwanted_executables >&2
        add_result "error" "check_unwanted_executables"
    fi
fi

# check_minitest_filenames OR check_rspec_filenames
if [[ -x "bin/check_minitest_filenames" ]]; then
    run_msg "check_minitest_filenames"
    if bin/check_minitest_filenames >/dev/null 2>&1; then
        add_result "success" "check_minitest_filenames"
    else
        bin/check_minitest_filenames >&2
        add_result "error" "check_minitest_filenames"
    fi
elif [[ -x "bin/check_rspec_filenames" ]]; then
    run_msg "check_rspec_filenames"
    if bin/check_rspec_filenames >/dev/null 2>&1; then
        add_result "success" "check_rspec_filenames"
    else
        bin/check_rspec_filenames >&2
        add_result "error" "check_rspec_filenames"
    fi
fi

# check_sorbet_typings
if [[ -x "bin/check_sorbet_typings" ]]; then
    run_msg "check_sorbet_typings"
    output=$(bin/check_sorbet_typings 2>&1)
    if [[ $? -eq 0 ]]; then
        add_result "success" "check_sorbet_typings"
    else
        echo "$output" >&2
        cat >&2 <<'GUIDANCE'

┌─ Sorbet Typing Guide ─────────────────────────────────────────────┐
│                                                                   │
│  Required typing levels:                                          │
│    # typed: strict  →  POROs, services, GraphQL types/mutations   │
│    # typed: true    →  models, controllers, config, initializers  │
│    # typed: false   →  test files, factory files (DSL-heavy)      │
│                                                                   │
│  Use the HIGHEST level you can without fighting Sorbet:           │
│    - Services/POROs should almost always be typed: strict          │
│    - Controllers/config may need typed: true due to DSL magic     │
│    - All methods in strict files need sig { } signatures          │
│                                                                   │
│  If Sorbet can't resolve a type, create an RBI shim:              │
│    sorbet/rbi/shims/my_class.rbi                                  │
│                                                                   │
│  Example:                                                         │
│    # typed: strict                                                │
│    class MyService                                                │
│      extend T::Sig                                                │
│      sig { params(name: String).returns(T::Boolean) }             │
│      def call(name) = name.present?                               │
│    end                                                            │
│                                                                   │
│  Check bin/check_sorbet_typings for exact directory requirements. │
└───────────────────────────────────────────────────────────────────┘
GUIDANCE
        add_result "error" "check_sorbet_typings"
    fi
fi

# check_sorbet_rbi
if [[ -x "bin/check_sorbet_rbi" ]]; then
    run_msg "check_sorbet_rbi"
    if bin/check_sorbet_rbi >/dev/null 2>&1; then
        add_result "success" "check_sorbet_rbi"
    else
        bin/check_sorbet_rbi >&2
        add_result "error" "check_sorbet_rbi"
    fi
fi

# ============================================================================
# PHASE 2: Tapioca RBI generation (keep type stubs up-to-date)
# ============================================================================
#
# Locally, we just run the generation commands — the agent often forgets these.
# We do NOT check git status after (that's for CI). The working dir is naturally dirty.
# The generation itself is the value: "don't forget to regenerate these files."

echo -e "${BLUE}─── Phase 2: Tapioca generation ───${NC}" >&2

check_docker

if [[ "$DOCKER_AVAILABLE" == "false" ]]; then
    echo -e "${YELLOW}Docker container 'app' is not running — skipping tapioca generation.${NC}" >&2
    add_result "skip" "Tapioca generation (Docker not running)"
else
    # tapioca require
    ck "tap-require"
    run_msg "tapioca require"
    if docker_exec bundle exec tapioca require >/dev/null 2>&1; then
        add_result "success" "tapioca require"
    else
        add_result "warn" "tapioca require failed (non-blocking)"
    fi

    # tapioca gems
    ck "tap-gems"
    run_msg "tapioca gems"
    if docker_exec bundle exec tapioca gems >/dev/null 2>&1; then
        add_result "success" "tapioca gems"
    else
        add_result "warn" "tapioca gems failed (non-blocking)"
    fi

    # tapioca annotations — only works on latest Rails (published for latest only)
    ck "tap-annotations"
    rails_major_minor=""
    if [[ -f "Gemfile" ]]; then
        rails_major_minor=$(grep -E '^\s*gem\s+["\x27]rails["\x27]' Gemfile | grep -oE '[0-9]+\.[0-9]+' | head -1)
    fi
    if [[ -n "$rails_major_minor" ]] && [[ "$(echo "$rails_major_minor < 8.1" | bc)" == "1" ]]; then
        add_result "skip" "tapioca annotations (Rails $rails_major_minor < 8.1)"
    else
        run_msg "tapioca annotations"
        if docker_exec bundle exec tapioca annotations >/dev/null 2>&1; then
            add_result "success" "tapioca annotations"
        else
            add_result "warn" "tapioca annotations failed (non-blocking)"
        fi
    fi

    # tapioca todo
    ck "tap-todo"
    run_msg "tapioca todo"
    if docker_exec bundle exec tapioca todo >/dev/null 2>&1; then
        add_result "success" "tapioca todo"
    else
        add_result "warn" "tapioca todo failed (non-blocking)"
    fi

    # tapioca dsl (needs DB)
    # Auto-detect tapioca database override from config files
    tapioca_db_env=$(detect_tapioca_db_override)

    if [[ -n "$tapioca_db_env" ]]; then
        # Resync: drop/create/schema:load a clean tapioca-specific database
        ck "tap-dsl-resync"
        run_msg "Resyncing tapioca database ($tapioca_db_env)"

        # Drop (ignore failure — DB may not exist on first run)
        docker_exec_with_env "$tapioca_db_env" rake db:drop >/dev/null 2>&1 || true

        if docker_exec_with_env "$tapioca_db_env" rake db:create db:schema:load >/dev/null 2>&1; then
            add_result "success" "tapioca dsl db resync"

            ck "tap-dsl"
            run_msg "tapioca dsl (clean schema)"
            if docker_exec_with_env "$tapioca_db_env" bundle exec tapioca dsl >/dev/null 2>&1; then
                add_result "success" "tapioca dsl (clean schema)"
            else
                add_result "warn" "tapioca dsl failed (non-blocking)"
            fi
        else
            add_result "warn" "tapioca dsl db resync failed"

            # Resync failed — fall back to dev database
            ck "tap-dsl"
            run_msg "tapioca dsl (fallback to dev DB)"
            if docker_exec bundle exec tapioca dsl >/dev/null 2>&1; then
                add_result "warn" "tapioca dsl (used dev DB — resync failed)"
            else
                add_result "warn" "tapioca dsl failed (non-blocking)"
            fi
        fi
    else
        # No tapioca db override detected — run against dev DB as before
        ck "tap-dsl"
        run_msg "tapioca dsl"
        if docker_exec bundle exec tapioca dsl >/dev/null 2>&1; then
            add_result "success" "tapioca dsl"
        else
            add_result "warn" "tapioca dsl failed (non-blocking)"
        fi
    fi
    # GraphQL schema dump — only if app/graphql files are dirty
    ck "graphql-dump"
    graphql_dirty=$(git status --porcelain 2>/dev/null | grep -v '^D' | grep 'app/graphql' || true)
    if [[ -n "$graphql_dirty" ]]; then
        run_msg "GraphQL schema dump"
        graphql_output=$(docker_exec bundle exec rake graphql:dump_schema 2>&1)
        if [[ $? -eq 0 ]]; then
            add_result "success" "GraphQL schema dump"
        else
            echo "$graphql_output" >&2
            add_result "error" "GraphQL schema dump"
        fi
    fi
fi

# ============================================================================
# PHASE 3: Security checks (non-blocking)
# ============================================================================

echo -e "${BLUE}─── Phase 3: Security checks ───${NC}" >&2

# Brakeman (host, static analysis — non-blocking, agent can't fix these)
ck "brakeman"
if [[ -x "bin/brakeman" ]]; then
    run_msg "Brakeman security scan"
    output=$(bin/brakeman --no-pager 2>&1)
    if [[ $? -eq 0 ]]; then
        add_result "success" "Brakeman security scan"
    else
        echo "$output" >&2
        add_result "warn" "Brakeman found issues (non-blocking)"
    fi
fi

# bundler-audit (host, static analysis — non-blocking, agent can't fix these)
ck "bundler-audit"
if [[ -x "bin/bundler-audit" ]]; then
    run_msg "bundler-audit"
    output=$(bin/bundler-audit 2>&1)
    if [[ $? -eq 0 ]]; then
        add_result "success" "bundler-audit"
    else
        echo "$output" >&2
        add_result "warn" "bundler-audit found vulnerabilities (non-blocking)"
    fi
fi

# ============================================================================
# SUMMARY
# ============================================================================

finalize_timing
print_summary

if [[ $ERROR_COUNT -gt 0 ]]; then
    exit 1
fi
exit 0
