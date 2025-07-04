#!/usr/bin/env bash
# smart-lint.sh - Intelligent project-aware code quality checks for Claude Code
#
# SYNOPSIS
#   smart-lint.sh [options]
#
# DESCRIPTION
#   Automatically detects project type and runs ALL quality checks.
#   Every issue found is blocking - code must be 100% clean to proceed.
#
# OPTIONS
#   --debug       Enable debug output
#   --fast        Skip slow checks (import cycles, security scans)
#
# EXIT CODES
#   0 - Success (all checks passed - everything is ✅ GREEN)
#   1 - General error (missing dependencies, etc.)
#   2 - ANY issues found - ALL must be fixed
#
# CONFIGURATION
#   Project-specific overrides can be placed in .claude-hooks-config.sh
#   See inline documentation for all available options.

# Don't use set -e - we need to control exit codes carefully
set +e

# ============================================================================
# COLOR DEFINITIONS AND UTILITIES
# ============================================================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Debug mode
CLAUDE_HOOKS_DEBUG="${CLAUDE_HOOKS_DEBUG:-0}"

# Logging functions
log_debug() {
    [[ "$CLAUDE_HOOKS_DEBUG" == "1" ]] && echo -e "${CYAN}[DEBUG]${NC} $*" >&2
}

log_info() {
    echo -e "${BLUE}[INFO]${NC} $*" >&2
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $*" >&2
}

log_success() {
    echo -e "${GREEN}[OK]${NC} $*" >&2
}

# Performance timing
time_start() {
    if [[ "$CLAUDE_HOOKS_DEBUG" == "1" ]]; then
        echo $(($(date +%s%N)/1000000))
    fi
}

time_end() {
    if [[ "$CLAUDE_HOOKS_DEBUG" == "1" ]]; then
        local start=$1
        local end=$(($(date +%s%N)/1000000))
        local duration=$((end - start))
        log_debug "Execution time: ${duration}ms"
    fi
}

# Check if a command exists
command_exists() {
    command -v "$1" &> /dev/null
}

# ============================================================================
# PROJECT DETECTION
# ============================================================================

# Helper function to find git root directory
find_git_root() {
    git rev-parse --show-toplevel 2>/dev/null || echo "."
}

# Helper function to get the relative path from git root to current directory
get_mono_repo_path() {
    local git_root=$(find_git_root)
    local current_dir=$(pwd)
    
    if [[ "$git_root" == "$current_dir" ]]; then
        echo ""
    else
        # Get relative path from git root to current directory
        echo "${current_dir#$git_root/}/"
    fi
}

detect_project_type() {
    local project_type="unknown"
    local types=()

    # Common exclude patterns for find commands
    local FIND_EXCLUDES="-path ./node_modules -prune -o -path ./vendor -prune -o -path ./.git -prune -o -path ./dist -prune -o -path ./build -prune -o -path ./.next -prune -o -path ./coverage -prune -o -path ./.cache -prune -o"

    # Go project
    if [[ -f "go.mod" ]] || [[ -f "go.sum" ]] || [[ -n "$(find . -maxdepth 3 $FIND_EXCLUDES -name "*.go" -type f -print -quit 2>/dev/null)" ]]; then
        types+=("go")
    fi

    # Python project
    if [[ -f "pyproject.toml" ]] || [[ -f "setup.py" ]] || [[ -f "requirements.txt" ]] || [[ -n "$(find . -maxdepth 3 $FIND_EXCLUDES -name "*.py" -type f -print -quit 2>/dev/null)" ]]; then
        types+=("python")
    fi

    # JavaScript/TypeScript project
    if [[ -f "package.json" ]] || [[ -f "tsconfig.json" ]] || [[ -n "$(find . -maxdepth 3 $FIND_EXCLUDES \( -name "*.js" -o -name "*.ts" -o -name "*.jsx" -o -name "*.tsx" \) -type f -print -quit 2>/dev/null)" ]]; then
        types+=("javascript")
    fi

    # Rust project
    if [[ -f "Cargo.toml" ]] || [[ -n "$(find . -maxdepth 3 $FIND_EXCLUDES -name "*.rs" -type f -print -quit 2>/dev/null)" ]]; then
        types+=("rust")
    fi

    # Ruby project
    if [[ -f "Gemfile" ]] || [[ -f ".ruby-version" ]] || [[ -f "Rakefile" ]] || [[ -n "$(find . -maxdepth 3 $FIND_EXCLUDES -name "*.rb" -type f -print -quit 2>/dev/null)" ]]; then
        types+=("ruby")
    fi

    # Nix project
    if [[ -f "flake.nix" ]] || [[ -f "default.nix" ]] || [[ -f "shell.nix" ]]; then
        types+=("nix")
    fi

    # Return primary type or "mixed" if multiple
    if [[ ${#types[@]} -eq 1 ]]; then
        project_type="${types[0]}"
    elif [[ ${#types[@]} -gt 1 ]]; then
        project_type="mixed:$(IFS=,; echo "${types[*]}")"
    fi

    log_debug "Detected project type: $project_type"
    echo "$project_type"
}

# ============================================================================
# SUMMARY TRACKING
# ============================================================================

declare -a CLAUDE_HOOKS_SUMMARY=()
declare -i CLAUDE_HOOKS_ERROR_COUNT=0

add_summary() {
    local level="$1"
    local message="$2"

    if [[ "$level" == "error" ]]; then
        CLAUDE_HOOKS_ERROR_COUNT+=1
        CLAUDE_HOOKS_SUMMARY+=("${RED}❌${NC} $message")
    else
        CLAUDE_HOOKS_SUMMARY+=("${GREEN}✅${NC} $message")
    fi
}

print_summary() {
    if [[ $CLAUDE_HOOKS_ERROR_COUNT -gt 0 ]]; then
        # Only show failures when there are errors
        echo -e "\n${BLUE}═══ Summary ═══${NC}" >&2
        for item in "${CLAUDE_HOOKS_SUMMARY[@]}"; do
            # Only print error items
            if [[ "$item" == *"❌"* ]]; then
                echo -e "$item" >&2
            fi
        done

        echo -e "\n${RED}Found $CLAUDE_HOOKS_ERROR_COUNT issue(s) that MUST be fixed!${NC}" >&2
        echo -e "${RED}════════════════════════════════════════════${NC}" >&2
        echo -e "${RED}❌ ALL ISSUES ARE BLOCKING ❌${NC}" >&2
        echo -e "${RED}════════════════════════════════════════════${NC}" >&2
        echo -e "${RED}Fix EVERYTHING above until all checks are ✅ GREEN${NC}" >&2
    fi
    # Don't print success summary - we'll handle that in the final message
}

# ============================================================================
# CONFIGURATION LOADING
# ============================================================================

load_config() {
    # Default configuration
    export CLAUDE_HOOKS_ENABLED="${CLAUDE_HOOKS_ENABLED:-true}"
    export CLAUDE_HOOKS_FAIL_FAST="${CLAUDE_HOOKS_FAIL_FAST:-false}"
    export CLAUDE_HOOKS_SHOW_TIMING="${CLAUDE_HOOKS_SHOW_TIMING:-false}"

    # Language enables
    export CLAUDE_HOOKS_GO_ENABLED="${CLAUDE_HOOKS_GO_ENABLED:-true}"
    export CLAUDE_HOOKS_PYTHON_ENABLED="${CLAUDE_HOOKS_PYTHON_ENABLED:-true}"
    export CLAUDE_HOOKS_JS_ENABLED="${CLAUDE_HOOKS_JS_ENABLED:-true}"
    export CLAUDE_HOOKS_RUST_ENABLED="${CLAUDE_HOOKS_RUST_ENABLED:-true}"
    export CLAUDE_HOOKS_RUBY_ENABLED="${CLAUDE_HOOKS_RUBY_ENABLED:-true}"
    export CLAUDE_HOOKS_NIX_ENABLED="${CLAUDE_HOOKS_NIX_ENABLED:-true}"

    # Project-specific overrides
    if [[ -f ".claude-hooks-config.sh" ]]; then
        source ".claude-hooks-config.sh" || {
            log_error "Failed to load .claude-hooks-config.sh"
            exit 2
        }
    fi

    # Quick exit if hooks are disabled
    if [[ "$CLAUDE_HOOKS_ENABLED" != "true" ]]; then
        log_info "Claude hooks are disabled"
        exit 0
    fi
}

# ============================================================================
# GO LINTING
# ============================================================================

lint_go() {
    if [[ "${CLAUDE_HOOKS_GO_ENABLED:-true}" != "true" ]]; then
        log_debug "Go linting disabled"
        return 0
    fi

    log_info "Running Go formatting and linting..."

    # Check if Makefile exists with fmt and lint targets
    if [[ -f "Makefile" ]]; then
        local has_fmt=$(grep -E "^fmt:" Makefile 2>/dev/null || echo "")
        local has_lint=$(grep -E "^lint:" Makefile 2>/dev/null || echo "")

        if [[ -n "$has_fmt" && -n "$has_lint" ]]; then
            log_info "Using Makefile targets"

            if ! make fmt >/dev/null 2>&1; then
                add_summary "error" "Go formatting failed (make fmt)"
            else
                add_summary "success" "Go code formatted"
            fi

            if ! make lint 2>&1; then
                add_summary "error" "Go linting failed (make lint)"
            else
                add_summary "success" "Go linting passed"
            fi
        else
            # Fallback to direct commands
            log_info "Using direct Go tools"

            # Format check
            local unformatted_files=$(gofmt -l . 2>/dev/null | grep -v vendor/ || true)

            if [[ -n "$unformatted_files" ]]; then
                if ! gofmt -w . >/dev/null 2>&1; then
                    add_summary "error" "Go formatting failed"
                fi
                # Don't report success - formatting was needed and applied
            else
                add_summary "success" "Go formatting correct"
            fi

            # Linting
            if command_exists golangci-lint; then
                if ! golangci-lint run --timeout=2m 2>&1; then
                    add_summary "error" "golangci-lint found issues"
                else
                    add_summary "success" "golangci-lint passed"
                fi
            elif command_exists go; then
                if ! go vet ./... 2>&1; then
                    add_summary "error" "go vet found issues"
                else
                    add_summary "success" "go vet passed"
                fi
            else
                log_error "No Go linting tools available - install golangci-lint or go"
            fi
        fi
    else
        # No Makefile, use direct commands
        log_info "Using direct Go tools"

        # Format check
        local unformatted_files=$(gofmt -l . 2>/dev/null | grep -v vendor/ || true)

        if [[ -n "$unformatted_files" ]]; then
            if ! gofmt -w . >/dev/null 2>&1; then
                add_summary "error" "Go formatting failed"
            fi
            # Don't report success - formatting was needed and applied
        else
            add_summary "success" "Go formatting correct"
        fi

        # Linting
        if command_exists golangci-lint; then
            if ! golangci-lint run --timeout=2m 2>&1; then
                add_summary "error" "golangci-lint found issues"
                exit_code=2
            else
                add_summary "success" "golangci-lint passed"
            fi
        elif command_exists go; then
            if ! go vet ./... 2>&1; then
                add_summary "error" "go vet found issues"
                exit_code=2
            else
                add_summary "success" "go vet passed"
            fi
        else
            log_error "No Go linting tools available - install golangci-lint or go"
        fi
    fi
}

# ============================================================================
# OTHER LANGUAGE LINTERS
# ============================================================================

lint_python() {
    if [[ "${CLAUDE_HOOKS_PYTHON_ENABLED:-true}" != "true" ]]; then
        log_debug "Python linting disabled"
        return 0
    fi

    log_info "Running Python linters..."

    # Black formatting
    if command_exists black; then
        if black . --check --quiet 2>/dev/null; then
            add_summary "success" "Python formatting correct"
        else
            black . --quiet 2>/dev/null
            add_summary "error" "Python files need formatting"
        fi
    fi

    # Linting
    if command_exists ruff; then
        if ! ruff check --fix . 2>&1; then
            add_summary "error" "Ruff found issues"
        else
            add_summary "success" "Ruff check passed"
        fi
    elif command_exists flake8; then
        if flake8 . 2>&1; then
            add_summary "success" "Flake8 check passed"
        else
            add_summary "error" "Flake8 found issues"
        fi
    fi

    return 0
}

lint_javascript() {
    if [[ "${CLAUDE_HOOKS_JS_ENABLED:-true}" != "true" ]]; then
        log_debug "JavaScript linting disabled"
        return 0
    fi

    log_info "Running JavaScript/TypeScript linters..."

    # Helper function to check if npm script exists
    npm_script_exists() {
        local script_name="$1"
        [[ -f "package.json" ]] && jq -e ".scripts.\"$script_name\"" package.json >/dev/null 2>&1
    }

    # Check for Prettier FIRST (formatting before linting)
    if [[ -f "package.json" ]]; then
        if command_exists npm; then
            # Try prettier:dirty:fix first, then prettier:dirty, then prettier:fix, then prettier
            if npm_script_exists "prettier:dirty:fix"; then
                log_info "Running npm run prettier:dirty:fix"
                if npm run prettier:dirty:fix 2>&1; then
                    add_summary "success" "Prettier formatting applied (dirty:fix)"
                else
                    add_summary "error" "Prettier formatting failed"
                fi
            elif npm_script_exists "prettier:dirty"; then
                log_info "Running npm run prettier:dirty"
                if npm run prettier:dirty 2>&1; then
                    add_summary "success" "Prettier formatting applied (dirty)"
                else
                    add_summary "error" "Prettier formatting failed"
                fi
            elif npm_script_exists "prettier:fix"; then
                log_info "Running npm run prettier:fix"
                if npm run prettier:fix 2>&1; then
                    add_summary "success" "Prettier formatting applied"
                else
                    add_summary "error" "Prettier formatting failed"
                fi
            elif npm_script_exists "prettier"; then
                log_info "Running npm run prettier"
                if npm run prettier 2>&1; then
                    add_summary "success" "Prettier check passed"
                else
                    add_summary "error" "Prettier found formatting issues"
                fi
            else
                # Fallback to direct prettier commands if config files exist
                if [[ -f ".prettierrc" ]] || [[ -f "prettier.config.js" ]] || [[ -f ".prettierrc.json" ]]; then
                    if command_exists prettier; then
                        if prettier --check . 2>/dev/null; then
                            add_summary "success" "Prettier formatting correct"
                        else
                            prettier --write . 2>/dev/null
                            add_summary "error" "Files need formatting with Prettier"
                        fi
                    elif command_exists npx; then
                        if npx prettier --check . 2>/dev/null; then
                            add_summary "success" "Prettier formatting correct"
                        else
                            npx prettier --write . 2>/dev/null
                            add_summary "error" "Files need formatting with Prettier"
                        fi
                    fi
                fi
            fi
        fi
    fi

    # Check for ESLint AFTER Prettier (lint after formatting)
    if [[ -f "package.json" ]] && grep -q "eslint" package.json 2>/dev/null; then
        if command_exists npm; then
            # Try lint:dirty:fix first, then lint:dirty, then fallback to lint
            if npm_script_exists "lint:dirty:fix"; then
                log_info "Running npm run lint:dirty:fix"
                if npm run lint:dirty:fix 2>&1; then
                    add_summary "success" "ESLint check passed (dirty:fix)"
                else
                    add_summary "error" "ESLint found issues"
                fi
            elif npm_script_exists "lint:dirty"; then
                log_info "Running npm run lint:dirty"
                if npm run lint:dirty 2>&1; then
                    add_summary "success" "ESLint check passed (dirty)"
                else
                    add_summary "error" "ESLint found issues"
                fi
            elif npm run lint --if-present 2>&1; then
                add_summary "success" "ESLint check passed"
            else
                add_summary "error" "ESLint found issues"
            fi
        fi
    fi

    return 0
}

lint_rust() {
    if [[ "${CLAUDE_HOOKS_RUST_ENABLED:-true}" != "true" ]]; then
        log_debug "Rust linting disabled"
        return 0
    fi

    log_info "Running Rust linters..."

    if command_exists cargo; then
        if cargo fmt -- --check 2>/dev/null; then
            add_summary "success" "Rust formatting correct"
        else
            cargo fmt 2>/dev/null
            add_summary "error" "Rust files need formatting"
        fi

        if cargo clippy --quiet -- -D warnings 2>&1; then
            add_summary "success" "Clippy check passed"
        else
            add_summary "error" "Clippy found issues"
        fi
    else
        log_info "Cargo not found, skipping Rust checks"
    fi

    return 0
}

lint_ruby() {
    if [[ "${CLAUDE_HOOKS_RUBY_ENABLED:-true}" != "true" ]]; then
        log_debug "Ruby linting disabled"
        return 0
    fi

    log_info "Running Ruby linters..."

    # RuboCop formatting and linting
    if command_exists rubocop; then
        local mono_path=$(get_mono_repo_path)
        local git_root=$(find_git_root)
        
        # Get dirty Ruby files
        local dirty_files=""
        if [[ -n "$mono_path" ]]; then
            # In a mono-repo subdirectory
            log_debug "Detected mono-repo structure with path: $mono_path"
            dirty_files=$(cd "$git_root" && git status --porcelain | cut -c4- | grep "^${mono_path}" | sed "s|^${mono_path}||" | grep -E '\.(rb|rake|erb)$' | tr '\n' ' ')
        else
            # In repo root or no git
            dirty_files=$(git status --porcelain 2>/dev/null | cut -c4- | grep -E '\.(rb|rake|erb)$' | tr '\n' ' ')
        fi
        
        if [[ -n "$dirty_files" ]]; then
            log_info "Running RuboCop on dirty files only"
            # Run rubocop on dirty files with auto-correct
            if echo "$dirty_files" | xargs -r rubocop --autocorrect-all 2>&1; then
                add_summary "success" "RuboCop check passed (dirty files)"
            else
                add_summary "error" "RuboCop found issues"
            fi
        else
            log_debug "No dirty Ruby files found, running full RuboCop"
            # Run rubocop on all files
            if rubocop --autocorrect-all 2>&1; then
                add_summary "success" "RuboCop check passed"
            else
                add_summary "error" "RuboCop found issues"
            fi
        fi
    else
        log_debug "RuboCop not found, skipping Ruby style checks"
    fi

    # Sorbet type checking
    if command_exists srb; then
        if [[ -n "$dirty_files" ]]; then
            log_info "Running Sorbet on dirty files only"
            # Run sorbet on dirty files
            if echo "$dirty_files" | xargs -r srb tc 2>&1; then
                add_summary "success" "Sorbet type check passed (dirty files)"
            else
                add_summary "error" "Sorbet type check failed"
            fi
        else
            log_debug "No dirty Ruby files found, running full Sorbet check"
            # Run sorbet on all files
            if srb tc 2>&1; then
                add_summary "success" "Sorbet type check passed"
            else
                add_summary "error" "Sorbet type check failed"
            fi
        fi
    else
        log_debug "Sorbet not found, skipping type checks"
    fi

    return 0
}

lint_nix() {
    if [[ "${CLAUDE_HOOKS_NIX_ENABLED:-true}" != "true" ]]; then
        log_debug "Nix linting disabled"
        return 0
    fi

    log_info "Running Nix linters..."

    # Find all .nix files
    local nix_files=$(find . -name "*.nix" -type f | grep -v -E "(result/|/nix/store/)" | head -20)

    if [[ -z "$nix_files" ]]; then
        log_debug "No Nix files found"
        return 0
    fi

    # Check formatting with nixpkgs-fmt or alejandra
    if command_exists nixpkgs-fmt; then
        if echo "$nix_files" | xargs nixpkgs-fmt --check 2>/dev/null; then
            add_summary "success" "Nix formatting correct"
        else
            echo "$nix_files" | xargs nixpkgs-fmt 2>/dev/null
            add_summary "error" "Nix files need formatting"
        fi
    elif command_exists alejandra; then
        if echo "$nix_files" | xargs alejandra --check 2>/dev/null; then
            add_summary "success" "Nix formatting correct"
        else
            echo "$nix_files" | xargs alejandra --quiet 2>/dev/null
            add_summary "error" "Nix files need formatting"
        fi
    fi

    # Static analysis with statix
    if command_exists statix; then
        if statix check 2>&1; then
            add_summary "success" "Statix check passed"
        else
            add_summary "error" "Statix found issues"
        fi
    fi

    return 0
}

# ============================================================================
# MAIN EXECUTION
# ============================================================================

# Parse command line options
FAST_MODE=false
while [[ $# -gt 0 ]]; do
    case $1 in
        --debug)
            export CLAUDE_HOOKS_DEBUG=1
            shift
            ;;
        --fast)
            FAST_MODE=true
            shift
            ;;
        *)
            echo "Unknown option: $1" >&2
            exit 2
            ;;
    esac
done

# Print header
echo "" >&2
echo "🔍 Style Check - Validating code formatting..." >&2
echo "────────────────────────────────────────────" >&2

# Load configuration
load_config

# Start timing
START_TIME=$(time_start)

# Detect project type
PROJECT_TYPE=$(detect_project_type)
log_info "Project type: $PROJECT_TYPE"

# Main execution
main() {
    # Handle mixed project types
    if [[ "$PROJECT_TYPE" == mixed:* ]]; then
        local types="${PROJECT_TYPE#mixed:}"
        IFS=',' read -ra TYPE_ARRAY <<< "$types"

        for type in "${TYPE_ARRAY[@]}"; do
            case "$type" in
                "go") lint_go ;;
                "python") lint_python ;;
                "javascript") lint_javascript ;;
                "rust") lint_rust ;;
                "ruby") lint_ruby ;;
                "nix") lint_nix ;;
            esac

            # Fail fast if configured
            if [[ "$CLAUDE_HOOKS_FAIL_FAST" == "true" && $CLAUDE_HOOKS_ERROR_COUNT -gt 0 ]]; then
                break
            fi
        done
    else
        # Single project type
        case "$PROJECT_TYPE" in
            "go") lint_go ;;
            "python") lint_python ;;
            "javascript") lint_javascript ;;
            "rust") lint_rust ;;
            "ruby") lint_ruby ;;
            "nix") lint_nix ;;
            "unknown")
                log_info "No recognized project type, skipping checks"
                ;;
        esac
    fi

    # Show timing if enabled
    time_end "$START_TIME"

    # Print summary
    print_summary

    # Return exit code - any issues mean failure
    if [[ $CLAUDE_HOOKS_ERROR_COUNT -gt 0 ]]; then
        return 2
    else
        return 0
    fi
}

# Run main function
main
exit_code=$?

# Final message and exit
if [[ $exit_code -eq 2 ]]; then
    echo -e "\n${RED}🛑 FAILED - Fix all issues above! 🛑${NC}" >&2
    echo -e "${YELLOW}📋 NEXT STEPS:${NC}" >&2
    echo -e "${YELLOW}  1. Fix the issues listed above${NC}" >&2
    echo -e "${YELLOW}  2. Verify the fix by running the lint command again${NC}" >&2
    echo -e "${YELLOW}  3. Continue with your original task${NC}" >&2
    exit 2
else
    # Always exit with 2 so Claude sees the continuation message
    echo -e "\n${YELLOW}👉 Style clean. Continue with your task.${NC}" >&2
    exit 2
fi
