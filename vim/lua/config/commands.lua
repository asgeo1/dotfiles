vim.api.nvim_create_user_command('InstallLspServers', function()
  local M = require 'lsp.install'
  M.install_npm_packages()
end, {})
