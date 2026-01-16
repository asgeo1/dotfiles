# proj.fish - Tmux project manager with fzf
# Usage:
#   proj           - show help (or start mode)
#   proj start     - fzf picker to start a configured tmuxinator project
#   proj stop      - fzf picker to stop running sessions (SPACE to multi-select)
#   proj list      - list running tmux sessions

function proj -d "Tmux project manager with fzf"
    switch $argv[1]
        case start
            _proj_start
        case stop ''
            _proj_stop
        case list running
            tmux list-sessions 2>/dev/null; or echo "No tmux sessions running"
        case '*'
            echo "Usage: proj [start|stop|list]"
            echo "  start  - fzf picker to start a configured project"
            echo "  stop   - fzf picker to stop running sessions (multi-select)"
            echo "  list   - show running sessions"
    end
end

function _proj_start
    # Get configured projects from tmuxinator
    set projects (tmuxinator list | tail -n +2 | tr ' ' '\n' | grep -v '^$')

    if test -z "$projects"
        echo "No tmuxinator projects configured"
        return 1
    end

    # FZF picker - nnn-style interface (single select for start)
    #   ctrl-j/k = navigate, type to filter, Esc = clear, Enter = select
    set selected (printf '%s\n' $projects | fzf \
        --cycle \
        --no-sort \
        --bind 'ctrl-j:down,ctrl-k:up' \
        --bind 'ctrl-n:down,ctrl-p:up' \
        --bind 'esc:clear-query' \
        --prompt="ctrl-j/k:nav  type:filter  esc:clear  enter:select > ")

    if test -n "$selected"
        tmuxinator start $selected
    end
end

function _proj_stop
    # Get running sessions
    set sessions (tmux list-sessions -F '#{session_name}' 2>/dev/null)

    if test -z "$sessions"
        echo "No tmux sessions running"
        return 1
    end

    # FZF picker - nnn-style interface:
    #   ctrl-j/k = navigate, Space = select, type to filter, Esc = clear, Enter = confirm
    set selected (printf '%s\n' $sessions | fzf \
        --multi \
        --cycle \
        --no-sort \
        --bind 'ctrl-j:down,ctrl-k:up' \
        --bind 'ctrl-n:down,ctrl-p:up' \
        --bind 'space:toggle+down' \
        --bind 'esc:clear-query' \
        --prompt="ctrl-j/k:nav  space:select  type:filter  esc:clear > ")

    if test -z "$selected"
        return 0
    end

    # Get current session (if we're inside tmux)
    set current_session ""
    if set -q TMUX
        set current_session (tmux display-message -p '#{session_name}')
    end

    # Stop other sessions first
    for session in $selected
        if test "$session" != "$current_session"
            _proj_stop_session $session
        end
    end

    # Stop current session last (if selected) - we'll be disconnected
    if contains $current_session $selected
        echo "Stopping current session: $current_session (you will be disconnected)"
        _proj_stop_session $current_session
    end
end

function _proj_stop_session -a session_name
    set config_file "$HOME/.tmuxinator/$session_name.yml"

    if test -f $config_file
        # Find the docker window line
        # Examples:
        #   - docker: ~/Projects/.../api && ./bin/start_services
        #   - docker: ~/Projects/.../api && GC_PORT=7083 ./bin/start_services
        #   - docker: cd ~/Projects/.../api && GC_PORT=7083 ./bin/start_services
        set docker_line (grep -E '^\s*-\s*docker:' $config_file)

        if test -n "$docker_line"
            # Extract directory: get text after "docker:", before "&&", strip "cd " prefix
            set docker_dir (echo $docker_line | sed 's/.*docker:[[:space:]]*//' | sed 's/[[:space:]]*&&.*//' | sed 's/^cd[[:space:]]*//' | sed "s|~|$HOME|")

            # Extract env vars (pattern: VAR=value before the actual command)
            # Look for XXX_PORT=nnnn or similar patterns after the &&
            set env_vars ""
            if string match -q '*&&*' $docker_line
                set after_ampersand (echo $docker_line | sed -E 's/.*&&\s*//')
                # Extract all VAR=value patterns (e.g., GC_PORT=7083 FOO=bar)
                set env_vars (echo $after_ampersand | grep -oE '[A-Z_]+=[^ ]+' | string join ' ')
            end

            if test -d "$docker_dir"
                echo "Stopping docker in $docker_dir..."
                if test -n "$env_vars"
                    echo "  (with env: $env_vars)"
                    eval $env_vars docker compose --project-directory "$docker_dir" stop 2>/dev/null
                else
                    docker compose --project-directory "$docker_dir" stop 2>/dev/null
                end
            end
        end
    end

    # Kill the tmux session
    echo "Killing session: $session_name"
    tmux kill-session -t $session_name
end
