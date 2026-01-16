# proj.fish - Tmux project manager with fzf
# Usage:
#   proj           - stop running sessions (default)
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

    # FZF picker
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

    # FZF picker
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

    # Get current session and current kitty window
    set current_session ""
    if set -q TMUX
        set current_session (tmux display-message -p '#{session_name}')
    end
    set current_kitty_window (kitty @ ls 2>/dev/null | jq -r '.[] | select(.is_focused) | .tabs[] | select(.is_focused) | .id' 2>/dev/null)

    # Separate into "2nd+" projects (end with digit) and base projects
    set secondary_sessions
    set base_sessions
    for session in $selected
        if string match -qr '[0-9]$' $session
            set -a secondary_sessions $session
        else
            set -a base_sessions $session
        end
    end

    # Stop secondary (2nd+) projects first, then base projects
    # But always stop current session last
    for session in $secondary_sessions
        if test "$session" != "$current_session"
            _proj_stop_session $session $current_kitty_window
        end
    end

    for session in $base_sessions
        if test "$session" != "$current_session"
            _proj_stop_session $session $current_kitty_window
        end
    end

    # Stop current session last (if selected) - we'll be disconnected
    if contains $current_session $selected
        echo ""
        echo "Stopping current session: $current_session (you will be disconnected)"
        _proj_stop_session $current_session $current_kitty_window
    end
end

function _proj_stop_session -a session_name current_kitty_window
    echo ""
    echo "=== Stopping: $session_name ==="

    set config_file "$HOME/.tmuxinator/$session_name.yml"

    if test -f $config_file
        # Find the docker window line
        set docker_line (grep -E '^\s*-\s*docker:' $config_file)

        if test -n "$docker_line"
            # Extract directory: get text after "docker:", before "&&", strip "cd " prefix
            set docker_dir (echo $docker_line | sed 's/.*docker:[[:space:]]*//' | sed 's/[[:space:]]*&&.*//' | sed 's/^cd[[:space:]]*//' | sed "s|~|$HOME|")

            if test -d "$docker_dir"
                # Get env vars for docker compose
                set env_cmd (_proj_get_docker_env "$docker_line" "$docker_dir")

                echo "Stopping docker in $docker_dir..."
                if test -n "$env_cmd"
                    echo "  (with env: $env_cmd)"
                    eval $env_cmd docker compose --project-directory "$docker_dir" stop
                else
                    docker compose --project-directory "$docker_dir" stop
                end
                echo "Docker stopped."
            end
        end
    end

    # Find and close the kitty window running this tmux session (if not current)
    _proj_close_kitty_window $session_name $current_kitty_window

    # Kill the tmux session
    echo "Killing tmux session: $session_name"
    tmux kill-session -t $session_name
    echo "Done with $session_name"
end

function _proj_get_docker_env -a docker_line docker_dir
    # First, check for explicit env vars in the tmuxinator command (e.g., PROJECT_PORT=7083)
    set env_vars ""
    if string match -q '*&&*' $docker_line
        set after_ampersand (echo $docker_line | sed -E 's/.*&&[[:space:]]*//')
        set env_vars (echo $after_ampersand | grep -oE '[A-Z_]+=[0-9]+' | head -1)
    end

    if test -n "$env_vars"
        echo $env_vars
        return
    end

    # No explicit env var - try to extract port from command args (e.g., ./bin/start_services 7020)
    set port_arg (echo $docker_line | grep -oE 'start_services[[:space:]]+[0-9]+' | grep -oE '[0-9]+')

    if test -z "$port_arg"
        # No port found
        return
    end

    # Found a port arg - now find the env var name from docker-compose.yml
    set compose_file "$docker_dir/docker-compose.yml"
    if not test -f "$compose_file"
        set compose_file "$docker_dir/docker-compose.yaml"
    end

    if test -f "$compose_file"
        # Look for pattern like ${PROJECT_PORT:-7010} and extract PROJECT_PORT
        set port_var (grep -oE '\$\{[A-Z_]+_PORT:-[0-9]+\}' "$compose_file" | head -1 | sed 's/\${//' | sed 's/:-[0-9]*}//' )

        if test -n "$port_var"
            echo "$port_var=$port_arg"
            return
        end
    end

    # Fallback: no env var found
    return
end

function _proj_close_kitty_window -a session_name current_kitty_window
    # Try to find and close the kitty window/tab running this tmux session
    # Skip if it's the current kitty window

    if not command -q kitty
        return
    end

    # Get kitty window info - look for windows with this session name in title
    set kitty_info (kitty @ ls 2>/dev/null)
    if test -z "$kitty_info"
        return
    end

    # Find tab ID that has this session name in its title
    set tab_id (echo $kitty_info | jq -r ".[] | .tabs[] | select(.title | contains(\"$session_name\")) | .id" 2>/dev/null | head -1)

    if test -n "$tab_id" -a "$tab_id" != "$current_kitty_window"
        echo "Closing kitty tab for $session_name..."
        kitty @ close-tab --match "id:$tab_id" 2>/dev/null
    end
end
