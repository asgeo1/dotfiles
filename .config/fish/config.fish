status --is-interactive; and theme_gruvbox "dark"

# use neovim
alias vim="nvim"

status --is-interactive; and source (rbenv init -|psub)

# Suppress fish welcome message. Use a blank space, as iterm tabs cover it for a
# few seconds
set fish_greeting " "

set -x EDITOR vim

# configures fzf with vim
set -x FZF_DEFAULT_COMMAND 'ag --nocolor -g ""'
set -x FZF_CTRL_T_COMMAND "$FZF_DEFAULT_COMMAND"
set -x FZF_ALT_C_COMMAND "$FZF_DEFAULT_COMMAND"

# Things I don't want to publish to github
source "$HOME/.secrets"

set -g fish_user_paths "/usr/local/sbin" $fish_user_paths

# mongo 3.4 needed for forex
set -g fish_user_paths "/usr/local/opt/mongodb@3.4/bin" $fish_user_paths

# postgresql 10 needed for mypostlabels
set -g fish_user_paths "/usr/local/opt/postgresql@10/bin" $fish_user_paths

# mysql 5.7 needed for fieldfolio
set -g fish_user_paths "/usr/local/opt/mysql@5.7/bin" $fish_user_paths
