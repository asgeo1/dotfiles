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

# Helper function to find a file in current or parent directories up to git root
find_project_file() {
    local filename="$1"
    local current_dir=$(pwd)
    
    # Check if we're in a git repo by trying to get the git root
    local git_root
    git_root=$(git rev-parse --show-toplevel 2>/dev/null)
    
    if [[ -z "$git_root" ]]; then
        # Not in a git repo, just check current directory
        if [[ -f "$filename" ]]; then
            echo "$(pwd)/$filename"
            return 0
        fi
        return 1
    fi
    
    # We're in a git repo, search upwards to git root
    while [[ "$current_dir" != "/" ]]; do
        if [[ -f "$current_dir/$filename" ]]; then
            echo "$current_dir/$filename"
            return 0
        fi
        
        # Stop at git root
        if [[ "$current_dir" == "$git_root" ]]; then
            # Check git root itself
            if [[ -f "$git_root/$filename" ]]; then
                echo "$git_root/$filename"
                return 0
            fi
            break
        fi
        
        # Move to parent directory
        current_dir=$(dirname "$current_dir")
    done
    
    return 1  # File not found
}

# Helper function to check if we're in a Ruby project context
is_ruby_project_context() {
    local current_dir=$(pwd)
    
    # Check current directory and all parent directories up to git root or filesystem root
    while [[ "$current_dir" != "/" ]]; do
        # Only Gemfile is a definitive Ruby project marker
        # .ruby-version alone doesn't make it a Ruby project
        if [[ -f "$current_dir/Gemfile" ]]; then
            return 0  # Found Ruby project marker
        fi
        
        # Stop at git root if we're in a git repo
        if [[ -d "$current_dir/.git" ]]; then
            break
        fi
        
        # Move to parent directory
        current_dir=$(dirname "$current_dir")
    done
    
    return 1  # No Ruby project markers found
}

# Helper function to check if we're in a Python project context
is_python_project_context() {
    local current_dir=$(pwd)
    
    # Check current directory and all parent directories up to git root or filesystem root
    while [[ "$current_dir" != "/" ]]; do
        # Check for definitive Python project markers
        # Note: .python-version alone doesn't make it a Python project
        if [[ -f "$current_dir/pyproject.toml" ]] || [[ -f "$current_dir/setup.py" ]] || [[ -f "$current_dir/requirements.txt" ]]; then
            return 0  # Found Python project marker
        fi
        
        # Stop at git root if we're in a git repo
        if [[ -d "$current_dir/.git" ]]; then
            break
        fi
        
        # Move to parent directory
        current_dir=$(dirname "$current_dir")
    done
    
    return 1  # No Python project markers found
}

detect_project_type() {
    local project_type="unknown"
    local types=()

    # Common exclude patterns for find commands (including dot directories)
    # Using eval to properly handle the find command with excludes
    find_with_excludes() {
        local pattern="$1"
        eval "find . -maxdepth 3 -path ./node_modules -prune -o -path ./vendor -prune -o -path './.*' -prune -o -path ./dist -prune -o -path ./build -prune -o -path ./coverage -prune -o $pattern -type f -print -quit 2>/dev/null"
    }

    # Go project
    if [[ -f "go.mod" ]] || [[ -f "go.sum" ]] || [[ -n "$(find_with_excludes '-name "*.go"')" ]]; then
        types+=("go")
    fi

    # Python project - only detect if we have Python project markers in current or parent directories
    if is_python_project_context; then
        # We're in a Python project context, now check if there are actual Python files to lint
        if [[ -f "pyproject.toml" ]] || [[ -f "setup.py" ]] || [[ -f "requirements.txt" ]] || [[ -n "$(find_with_excludes '-name "*.py"')" ]]; then
            types+=("python")
        fi
    fi

    # JavaScript/TypeScript project - search upwards for package.json
    # Note: tsconfig.json alone doesn't make it a JS project, package.json is required
    if find_project_file "package.json" >/dev/null; then
        types+=("javascript")
    fi

    # Rust project
    if [[ -f "Cargo.toml" ]] || [[ -n "$(find_with_excludes '-name "*.rs"')" ]]; then
        types+=("rust")
    fi

    # Ruby project - only detect if we have Ruby project markers in current or parent directories
    if is_ruby_project_context; then
        # We're in a Ruby project context, now check if there are actual Ruby files to lint
        if [[ -f "Gemfile" ]] || [[ -f ".ruby-version" ]] || [[ -f "Rakefile" ]] || [[ -n "$(find_with_excludes '-name "*.rb"')" ]]; then
            types+=("ruby")
        fi
    fi

    # PHP project - search upwards for composer.json
    if find_project_file "composer.json" >/dev/null || find_project_file "composer.lock" >/dev/null || [[ -n "$(find_with_excludes '-name "*.php"')" ]]; then
        types+=("php")
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
    export CLAUDE_HOOKS_PHP_ENABLED="${CLAUDE_HOOKS_PHP_ENABLED:-true}"
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

    # Find package.json in current or parent directories
    local package_json_path=$(find_project_file "package.json")
    if [[ -z "$package_json_path" ]]; then
        log_debug "No package.json found"
        return 0
    fi

    # Get the directory containing package.json
    local project_dir=$(dirname "$package_json_path")
    
    # Helper function to check if npm script exists
    npm_script_exists() {
        local script_name="$1"
        jq -e ".scripts.\"$script_name\"" "$package_json_path" >/dev/null 2>&1
    }

    # Run npm commands from the project directory
    (
        cd "$project_dir" || return 1
        
        # Check for Prettier FIRST (formatting before linting)
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

        # Check for ESLint AFTER Prettier (lint after formatting)
        if grep -q "eslint" "$package_json_path" 2>/dev/null; then
            # Try lint:dirty:fix first, then lint:dirty, then lint:fix, then fallback to lint
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
            elif npm_script_exists "lint:fix"; then
                log_info "Running npm run lint:fix"
                if npm run lint:fix 2>&1; then
                    add_summary "success" "ESLint check passed (fix)"
                else
                    add_summary "error" "ESLint found issues"
                fi
            elif npm_script_exists "lint"; then
                log_info "Running npm run lint"
                if npm run lint 2>&1; then
                    add_summary "success" "ESLint check passed"
                else
                    add_summary "error" "ESLint found issues"
                fi
            fi
        fi

        # Check for TypeScript type checking AFTER linting
        if [[ -f "tsconfig.json" ]] || [[ -f "jsconfig.json" ]]; then
            # Try npm run typecheck first
            if npm_script_exists "typecheck"; then
                log_info "Running npm run typecheck"
                if npm run typecheck 2>&1; then
                    add_summary "success" "TypeScript typecheck passed"
                else
                    add_summary "error" "TypeScript typecheck found issues"
                fi
            elif command_exists npx; then
                log_info "Running npx tsc --noEmit"
                if npx tsc --noEmit 2>&1; then
                    add_summary "success" "TypeScript typecheck passed"
                else
                    add_summary "error" "TypeScript typecheck found issues"
                fi
            elif command_exists tsc; then
                log_info "Running tsc --noEmit"
                if tsc --noEmit 2>&1; then
                    add_summary "success" "TypeScript typecheck passed"
                else
                    add_summary "error" "TypeScript typecheck found issues"
                fi
            fi
        elif command_exists npx; then
            log_info "Running npx tsc --noEmit"
            if npx tsc --noEmit 2>&1; then
                add_summary "success" "TypeScript typecheck passed"
            else
                add_summary "error" "TypeScript typecheck found issues"
            fi
        elif command_exists tsc; then
            log_info "Running tsc --noEmit"
            if tsc --noEmit 2>&1; then
                add_summary "success" "TypeScript typecheck passed"
            else
                add_summary "error" "TypeScript typecheck found issues"
            fi
        fi
    )  # Close the subshell

    return 0
}

lint_rust() {
    if [[ "${CLAUDE_HOOKS_RUST_ENABLED:-true}" != "true" ]]; then
        log_debug "Rust linting disabled"
        return 0
    fi

    log_info "Running Rust linters..."

    if command_exists cargo; then
        # Check if there's a Cargo.toml in the current directory (direct Rust project)
        if [[ -f "Cargo.toml" ]]; then
            # We're in a single Rust project, run the checks directly
            lint_rust_single_project
        else
            # Check if this is a monorepo with Rust sub-projects
            local rust_subprojects=($(find . -maxdepth 3 -name "Cargo.toml" -type f 2>/dev/null | sed 's|/Cargo.toml||' | sort))
            
            if [[ ${#rust_subprojects[@]} -gt 0 ]]; then
                log_info "Found ${#rust_subprojects[@]} Rust sub-project(s) in monorepo, running checks on each:"
                
                for project_dir in "${rust_subprojects[@]}"; do
                    log_info "  → Checking $project_dir"
                    
                    # Run linting in each sub-project directory
                    (
                        cd "$project_dir" || return 1
                        lint_rust_single_project
                    )
                done
                return 0
            else
                log_info "Rust files detected in repo, but cargo commands must be run from within a Rust project"
                return 0
            fi
        fi
    else
        log_info "Cargo not found, skipping Rust checks"
    fi

    return 0
}

# Helper function to run Rust linting in a single project directory
lint_rust_single_project() {
    local rust_errors_before=$CLAUDE_HOOKS_ERROR_COUNT

    if cargo fmt -- --check 2>/dev/null; then
        add_summary "success" "Rust formatting correct"
    else
        cargo fmt 2>/dev/null
        add_summary "error" "Rust files need formatting"
    fi

    # Note: We run clippy but not cargo check because clippy includes compilation checks
    # Running both would be redundant - clippy will fail if there are type errors
    if cargo clippy --quiet -- -D warnings 2>&1; then
        add_summary "success" "Clippy check passed"
    else
        add_summary "error" "Clippy found issues"
    fi

    # Run project-specific checks only if no Rust errors so far
    local rust_errors_after=$CLAUDE_HOOKS_ERROR_COUNT
    if [[ $rust_errors_after -eq $rust_errors_before && -f "bin/project-checks" ]]; then
        log_info "Running project-specific checks..."
        # Capture both stdout and stderr
        local project_output
        project_output=$(bash bin/project-checks 2>&1)
        local project_exit_code=$?

        if [[ $project_exit_code -eq 0 ]]; then
            # Success - only show output if in debug mode
            if [[ "$CLAUDE_HOOKS_DEBUG" == "1" ]] && [[ -n "$project_output" ]]; then
                echo "$project_output" >&2
            fi
            add_summary "success" "Project checks passed"
        else
            # Failure - always show output
            if [[ -n "$project_output" ]]; then
                echo "$project_output" >&2
            fi
            add_summary "error" "Project checks failed"
        fi
    fi
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

        # Get dirty Ruby files, NOTE excluding .erb files, because sorbet and rubocop don't handle them
        local dirty_files=""
        if [[ -n "$mono_path" ]]; then
            # In a mono-repo subdirectory
            log_debug "Detected mono-repo structure with path: $mono_path"
            dirty_files=$(cd "$git_root" && git status --porcelain | cut -c4- | grep "^${mono_path}" | sed "s|^${mono_path}||" | grep -E '\.(rb|rake)$' | tr '\n' ' ')
        else
            # In repo root or no git
            dirty_files=$(git status --porcelain 2>/dev/null | cut -c4- | grep -E '\.(rb|rake)$' | tr '\n' ' ')
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

lint_php() {
    if [[ "${CLAUDE_HOOKS_PHP_ENABLED:-true}" != "true" ]]; then
        log_debug "PHP linting disabled"
        return 0
    fi

    log_info "Running PHP linters..."

    # Find composer.json in current or parent directories
    local composer_json_path=$(find_project_file "composer.json")
    if [[ -z "$composer_json_path" ]]; then
        log_debug "No composer.json found"
        return 0
    fi

    # Get the directory containing composer.json
    local project_dir=$(dirname "$composer_json_path")
    
    # Helper function to check if composer script exists
    composer_script_exists() {
        local script_name="$1"
        jq -e ".scripts.\"$script_name\"" "$composer_json_path" >/dev/null 2>&1
    }

    # Run composer commands from the project directory
    (
        cd "$project_dir" || return 1
        
        # Check for composer formatting commands
        if command_exists composer; then
            # Try format:dirty:fix first, then format:dirty, then format:fix, then format
            if composer_script_exists "format:dirty:fix"; then
                log_info "Running composer format:dirty:fix"
                if composer format:dirty:fix 2>&1; then
                    add_summary "success" "PHP formatting applied (dirty:fix)"
                else
                    add_summary "error" "PHP formatting failed"
                fi
            elif composer_script_exists "format:dirty"; then
                log_info "Running composer format:dirty"
                if composer format:dirty 2>&1; then
                    add_summary "success" "PHP formatting applied (dirty)"
                else
                    add_summary "error" "PHP formatting failed"
                fi
            elif composer_script_exists "format:fix"; then
                log_info "Running composer format:fix"
                if composer format:fix 2>&1; then
                    add_summary "success" "PHP formatting applied"
                else
                    add_summary "error" "PHP formatting failed"
                fi
            elif composer_script_exists "format"; then
                log_info "Running composer format"
                if composer format 2>&1; then
                    add_summary "success" "PHP format check passed"
                else
                    add_summary "error" "PHP found formatting issues"
                fi
            else
                log_debug "No composer format scripts found"
            fi
        
            # Check for PHP linting AFTER formatting
            # Try lint:dirty:fix first, then lint:dirty, then lint:fix, then fallback to lint
            if composer_script_exists "lint:dirty:fix"; then
                log_info "Running composer lint:dirty:fix"
                if composer lint:dirty:fix 2>&1; then
                    add_summary "success" "PHP linting passed (dirty:fix)"
                else
                    add_summary "error" "PHP linting found issues"
                fi
            elif composer_script_exists "lint:dirty"; then
                log_info "Running composer lint:dirty"
                if composer lint:dirty 2>&1; then
                    add_summary "success" "PHP linting passed (dirty)"
                else
                    add_summary "error" "PHP linting found issues"
                fi
            elif composer_script_exists "lint:fix"; then
                log_info "Running composer lint:fix"
                if composer lint:fix 2>&1; then
                    add_summary "success" "PHP linting passed (fix)"
                else
                    add_summary "error" "PHP linting found issues"
                fi
            elif composer_script_exists "lint"; then
                log_info "Running composer lint"
                if composer lint 2>&1; then
                    add_summary "success" "PHP linting passed"
                else
                    add_summary "error" "PHP linting found issues"
                fi
            else
                log_debug "No composer lint scripts found"
            fi
        else
            log_debug "Composer not found, skipping PHP formatting and linting checks"
        fi
    )  # Close the subshell

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
                "php") lint_php ;;
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
            "php") lint_php ;;
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
