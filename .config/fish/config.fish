# use neovim
alias vim="nvim"

################################################################################
# NNN
#
# -e = text in $VISUAL/$EDITOR/vi
# -a = auto NNN_FIFO
# -H = show hidden files
alias nnn="nnn -e -a -H"

# context colors, each context a different color
set -x NNN_COLORS '4231'

# set -x NNN_PLUG "f:fzcd;o:fzopen;z:fzz;d:diffs;t:treeview;p:preview-tui"
set -x NNN_PLUG "x:_chmod +x $nnn;p:preview-tui;f:fzcd;i:imgview"

# for preview-tui
# NOTE: the actual socket is defined in `.config/kitty/macos-launch-services-cmdline`
set -x KITTY_LISTEN_ON "unix:/tmp/mykitty"

# Not working :-(
# source ~/.local/share/icons-in-terminal/icons.fish

################################################################################

# Suppress fish welcome message. Use a blank space, as iterm tabs cover it for a
# few seconds
set fish_greeting " "

set -x VISUAL nvim
set -x EDITOR $VISUAL

# configures fzf with vim
set -x FZF_DEFAULT_COMMAND 'ag --nocolor -g ""'
set -x FZF_CTRL_T_COMMAND "$FZF_DEFAULT_COMMAND"
set -x FZF_ALT_C_COMMAND "$FZF_DEFAULT_COMMAND"

# Things I don't want to publish to github
source "$HOME/.secrets"

set -g fish_user_paths "/opt/homebrew/bin" $fish_user_paths

# customise the path
set -x PATH "$HOME/Projects/dotfiles/bin" $PATH
set -x PATH "$HOME/Library/Android/sdk/tools" $PATH
set -x PATH "$HOME/Library/Android/sdk/platform-tools" $PATH
set -x PATH "$HOME/Library/Android/sdk/cmdline-tools/latest/bin" $PATH
set -x PATH "$HOME/.node/bin" $PATH
set -x PATH "$HOME/.rbenv/bin" $PATH
set -x PATH "$HOME/.phpenv/bin" $PATH
set -x PATH "$HOME/.nodenv/bin" $PATH
set -x PATH "$HOME/.pyenv/bin" $PATH
set -x PATH "$HOME/.goenv/bin" $PATH
set -x PATH "$HOME/.cargo/bin" $PATH
set -x PATH "$HOME/.local/bin" $PATH
set -x PATH "./node_modules/.bin" $PATH
set -x PATH "$HOME/.composer/vendor/bin" $PATH
set -x PATH "/opt/homebrew/opt/libpq/bin" $PATH

set -x ANDROID_SDK_ROOT "$HOME/Library/Android/sdk" # new
set -x ANDROID_HOME "$HOME/Library/Android/sdk" # deprecated

# Use jdk bundled by Android Studio, has less issues
# set -x JAVA_HOME "/Applications/Android Studio.app/Contents/jre/Contents/Home"
set -x JAVA_HOME "/Applications/Android Studio.app/Contents/jbr/Contents/Home"

set -x PATH "$JAVA_HOME/bin" $PATH

set -x GOENV_ROOT "$HOME/.goenv"

# for tmuxinator:
set -x DISABLE_AUTO_TITLE true

# for fastlane
set -x LC_ALL en_AU.UTF-8
set -x LANG en_AU.UTF-8

set -g fish_user_paths "/usr/local/opt/icu4c/bin" $fish_user_paths
set -g fish_user_paths "/usr/local/opt/icu4c/sbin" $fish_user_paths

status --is-interactive; and source (rbenv init -|psub)
# status --is-interactive; and source (phpenv init -|psub)
status --is-interactive; and source (nodenv init -|psub)
status --is-interactive; and source (pyenv init -|psub)
status --is-interactive; and source (goenv init -|psub)
