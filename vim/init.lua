require 'util.utils'
require 'config.options'
require 'config.lazy'
require 'lsp'
require 'config.keymaps'

require('util.lists').setup()
require 'config.autocmds'

-- LANGUAGE SERVER DEPENDENCIES:
--
-- npm install -g typescript-language-server
-- npm install -g vscode-langservers-extracted
-- npm install -g cssmodules-language-server
-- npm install -g css-variables-language-server
-- npm install -g vim-language-server
-- npm install -g sql-language-server
-- npm install -g bash-language-server
-- npm install -g dockerfile-language-server-nodejs
-- npm install -g @microsoft/compose-language-service
-- npm install -g pyright
-- npm install -g yaml-language-server
-- npm install -g @tailwindcss/language-server
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
