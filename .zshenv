export PATH=/opt/homebrew/bin:/usr/local/bin:/usr/local/sbin:/usr/bin:/bin:/usr/sbin:/sbin:/usr/X11/bin
export PATH="$HOME/Projects/dotfiles/bin:$PATH"
export PATH="$HOME/.node/bin:$PATH"
export PATH="$HOME/.rbenv/bin:$PATH"
export PATH="$HOME/.rbenv/bin:$PATH"
export PATH="$HOME/.phpenv/bin:$PATH"
export PATH="$HOME/.pyenv/bin:$PATH"
export PATH="./node_modules/.bin:$PATH"
export PATH="$HOME/Library/Android/sdk/tools:$PATH"
export PATH="$HOME/Library/Android/sdk/platform-tools:$PATH"
export PATH="$HOME/Library/Android/sdk/cmdline-tools/latest/bin:$PATH"
export PATH="/opt/homebrew/opt/mysql-client/bin:$PATH"
export ANDROID_HOME="$HOME/Library/Android/sdk" # deprecated
export ANDROID_SDK_ROOT="$HOME/Library/Android/sdk" # new

# Set NDK_HOME to the latest NDK version if NDK directory exists
if [ -d "$ANDROID_HOME/ndk" ]; then
    export NDK_HOME="$ANDROID_HOME/ndk/$(ls -1 "$ANDROID_HOME/ndk/" | sort -V | tail -1)"
fi

export EDITOR=vim
export OPENSSL_ROOT_DIR="/usr/local/Cellar/openssl/1.0.2l"

# for tmuxinator:
export DISABLE_AUTO_TITLE=true

# Things I don't want to publish to github
[[ -s "$HOME/.secrets" ]] && source "$HOME/.secrets"

# adding this, as `UseKeychain` in .ssh/config not working for some reason
# ssh-add -K 2>/dev/null;
export GOENV_ROOT="$HOME/.goenv"
export PATH="$GOENV_ROOT/bin:$PATH"
eval "$(goenv init -)"
. "$HOME/.cargo/env"
