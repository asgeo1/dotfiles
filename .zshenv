export PATH=/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/usr/X11/bin
export PATH="/Applications/Postgres.app/Contents/MacOS/bin:$PATH"
export PATH="$HOME/Projects/dotfiles/bin:$PATH"
export PATH="/usr/local/php54/bin:$PATH"
#export DYLD_LIBRARY_PATH="/usr/oracle/instantclient_10_2"

# Things I don't want to publish to github
[[ -s "$HOME/.secrets" ]] && source "$HOME/.secrets"
