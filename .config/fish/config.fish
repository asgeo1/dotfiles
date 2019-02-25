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

# customise the path
set -x PATH "$HOME/Projects/dotfiles/bin" $PATH
set -x PATH "$HOME/Development/Android/sdk/tools" $PATH
set -x PATH "$HOME/Development/Android/sdk/platform-tools" $PATH
set -x PATH "$HOME/Development/Android/ndk" $PATH
set -x PATH "$HOME/.node/bin" $PATH
set -x PATH "$HOME/.rbenv/bin" $PATH
set -x PATH "./node_modules/.bin" $PATH
set -x PATH "$HOME/Development/flutter/bin" $PATH

set -x ANDROID_HOME "$HOME/Development/Android/sdk"
set -x JAVA_HOME "/Library/Java/JavaVirtualMachines/jdk1.8.0_45.jdk/Contents/Home"

# for tmuxinator:
set -x DISABLE_AUTO_TITLE true