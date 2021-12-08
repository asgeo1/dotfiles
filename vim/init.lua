require 'utils'
require 'settings'
require 'plugins'
require 'lsp'
require 'galaxyline.evilline'
require 'mappings'

require('lists').setup()
require 'autocmds'

-- DEPENDENCIES:
--
-- go install golang.org/x/tools/gopls@latest
-- pip install 'python-language-server[all]'
-- npm install -g typescript-language-server
-- npm install -g vim-language-server
-- npm install -g vscode-json-languageserver
-- npm i -g sql-language-server
-- npm install --global vscode-css-languageserver-bin
-- npm install --global vscode-html-languageserver-bin
-- npm i -g bash-language-server
-- npm install -g dockerfile-language-server-nodejs
-- gem install solargraph
-- yarn global add yaml-language-server
-- brew install hashicorp/tap/terraform-ls
-- sudo npm install -g pyright
-- npm i -g sql-language-server
-- npm i -g vscode-langservers-extracted
-- npm install -g vscode-json-languageserver
-- npm install -g yaml-language-server
--
--
-- git clone https://github.com/sumneko/lua-language-server
-- cd lua-language-server
-- git submodule update --init --recursive
-- cd 3rd/luamake
-- ./compile/install.sh
-- cd ../..
-- ./3rd/luamake/luamake rebuild
--
--
-- $ cd ~/home/you/somewhere
-- $ git clone git@github.com:phpactor/phpactor
-- $ cd phpactor
-- $ composer install
-- $ cd /usr/local/bin
-- $ sudo ln -s ~/your/projects/phpactor/bin/phpactor phpactor
