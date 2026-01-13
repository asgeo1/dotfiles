vim.api.nvim_create_user_command('InstallLspServers', function()
  local M = require 'lsp.install'
  M.install_npm_packages()
end, {})

vim.api.nvim_create_user_command('LspStatus', function()
  local M = require 'lsp.status'
  M.show_status()
end, {})

vim.api.nvim_create_user_command('StripTrailingWhitespace', function()
  local save = vim.fn.winsaveview()
  vim.cmd [[keeppatterns %s/\s\+$//e]]
  vim.fn.winrestview(save)
end, {})
