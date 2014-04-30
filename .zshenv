export PATH=/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/usr/X11/bin
export PATH="/Applications/Postgres93.app/Contents/MacOS/bin:$PATH"
export PATH="$HOME/Projects/dotfiles/bin:$PATH"
export PATH="$HOME/Development/Android/sdk/tools:$PATH"
export PATH="$HOME/Development/Android/sdk/platform-tools:$PATH"
export PATH="$HOME/Development/Android/ndk:$PATH"
export ANDROID_HOME="$HOME/Development/Android/sdk"
export JAVA_HOME="/Library/Java/JavaVirtualMachines/jdk1.7.0_07.jdk/Contents/Home"
export QCAR="$HOME/Development/Android/vuforia-sdk-android-2-8-7/build/java/vuforia/Vuforia.jar"
export QCAR_SDK_ROOT="$HOME/Development/Android/vuforia-sdk-android-2-8-7"
#export DYLD_LIBRARY_PATH="/usr/oracle/instantclient_10_2"

# Things I don't want to publish to github
[[ -s "$HOME/.secrets" ]] && source "$HOME/.secrets"
