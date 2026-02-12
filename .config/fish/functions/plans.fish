function plans -d "Browse Claude Code plan files"
    set plans_dir "$HOME/.claude/plans"

    if not test -d "$plans_dir"
        echo "No plans directory found at $plans_dir"
        return 1
    end

    set selected (ls -t "$plans_dir"/*.md | fzf \
        --cycle \
        --no-sort \
        --preview 'bat --color=always --style=plain --language=md {}' \
        --preview-window 'right:60%:border-left' \
        --bind 'ctrl-j:down,ctrl-k:up' \
        --bind 'ctrl-d:preview-half-page-down,ctrl-u:preview-half-page-up' \
        --bind 'ctrl-y:execute-silent(echo -n {} | pbcopy)+abort' \
        --bind 'enter:execute-silent(echo -n {} | pbcopy)+abort' \
        --bind 'esc:abort' \
        --prompt="j/k:nav  d/u:scroll  enter/y:copy path > " \
        --header "Claude Code Plans (newest first)")

    if test -n "$selected"
        echo $selected
    end
end
