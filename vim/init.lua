require 'util.utils'
require 'config.options'
require 'config.lazy'
require 'lsp'
require 'config.keymaps'
require 'config.commands'

require('util.lists').setup()
require 'config.autocmds'

-- LANGUAGE SERVER DEPENDENCIES:
--
-- NOTE:
-- Language servers written as npm / node package, can be installed with :InstallLspServers command
--
-- OTHER LSPs
--
-- # GO
-- https://github.com/golang/tools/tree/master/gopls
-- go install golang.org/x/tools/gopls@latest
--
-- # LUA
-- git clone https://github.com/sumneko/lua-language-server
-- cd lua-language-server
-- git submodule update --init --recursive
-- cd 3rd/luamake
-- ./compile/install.sh
-- cd ../..
-- ./3rd/luamake/luamake rebuild
--
-- # PHP
-- https://github.com/phpactor/phpactor
-- $ cd ~/home/you/somewhere
-- $ git clone git@github.com:phpactor/phpactor
-- $ cd phpactor
-- $ composer install
-- $ cd /usr/local/bin
-- $ sudo ln -s ~/your/projects/phpactor/bin/phpactor phpactor
--
-- # RUBY
-- gem install rubocop
-- gem install sorbet
-- gem install ruby-lsp
-- gem install ruby-lsp-rails
-- gem install ruby-lsp-rspec
--
--
-- NOTE:  also don't forget to `:TSInstall` or `:TSUpdate` for treesitter
