export PATH=/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/usr/X11/bin
export PATH="/Applications/Postgres.app/Contents/MacOS/bin:$PATH"
export PATH="$HOME/Projects/dotfiles/bin:$PATH"
export PATH="/usr/local/php54/bin:$PATH"
export PATH="$HOME/Development/Android/sdk/tools:$PATH"
export PATH="$HOME/Development/Android/sdk/platform-tools:$PATH"
export ANDROID_HOME="$HOME/Development/Android/sdk"
export JAVA_HOME="/Library/Java/JavaVirtualMachines/jdk1.7.0_07.jdk/Contents/Home"
#export DYLD_LIBRARY_PATH="/usr/oracle/instantclient_10_2"

# Things I don't want to publish to github
[[ -s "$HOME/.secrets" ]] && source "$HOME/.secrets"
