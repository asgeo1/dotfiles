export PATH=/usr/local/bin:/usr/local/sbin:/usr/bin:/bin:/usr/sbin:/sbin:/usr/X11/bin
export PATH="$HOME/Projects/dotfiles/bin:$PATH"
export PATH="$HOME/Development/Android/sdk/tools:$PATH"
export PATH="$HOME/Development/Android/sdk/platform-tools:$PATH"
export PATH="$HOME/Development/Android/ndk:$PATH"
export PATH="$HOME/.node/bin:$PATH"
export PATH="$HOME/.rbenv/bin:$PATH"
export PATH="./node_modules/.bin:$PATH"
export ANDROID_HOME="$HOME/Development/Android/sdk"
export JAVA_HOME="/Library/Java/JavaVirtualMachines/jdk1.8.0_45.jdk/Contents/Home"
export QCAR="$HOME/Development/Android/vuforia-sdk-android-2-8-8/build/java/vuforia/Vuforia.jar"
export QCAR_SDK_ROOT="$HOME/Development/Android/vuforia-sdk-android-2-8-8"

export NVIM_TUI_ENABLE_CURSOR_SHAPE=1
export EDITOR=vim
export OPENSSL_ROOT_DIR="/usr/local/Cellar/openssl/1.0.2l"

# for tmuxinator:
export DISABLE_AUTO_TITLE=true

# Things I don't want to publish to github
[[ -s "$HOME/.secrets" ]] && source "$HOME/.secrets"

# adding this, as `UseKeychain` in .ssh/config not working for some reason
# ssh-add -K 2>/dev/null;
