export PATH=/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/usr/X11/bin
#export PATH=~/.rvm/bin:$PATH
#export PATH=~/.rvm/gems/ruby-1.9.2-p290@rails31/bin:$PATH
#export PATH=~/.rvm/gems/ruby-1.9.2-p290@rails31:$PATH
[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM function
export PATH=/Library/PostgreSQL/9.0/bin:$PATH
export PATH=$HOME/Projects/dotfiles/bin:$PATH
export PATH=/usr/local/php54/bin:$PATH
export DYLD_LIBRARY_PATH=/usr/oracle/instantclient_10_2

# Things I don't want to publish to github
[[ -s "$HOME/.secrets" ]] && source "$HOME/.secrets"
