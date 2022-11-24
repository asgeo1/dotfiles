local utils = require 'utils'
local M = {}

local format_disabled_var = function()
  return string.format('format_disabled_%s', vim.bo.filetype)
end

local format_options_var = function()
  return string.format('format_options_%s', vim.bo.filetype)
end

local format_options_prettier = {
  -- global defaults:
  --
  -- it's confusing to set these here. Just use whatever settings are in the
  -- project's `.prettierrc`
  --
  -- tabWidth = 2,
  -- tabs = false,
  -- singleQuote = true,

  configPrecedence = 'prefer-file',
  --configPrecedence = "file-override"
}

vim.g.format_options_typescript = format_options_prettier
vim.g.format_options_javascript = format_options_prettier
vim.g.format_options_typescriptreact = format_options_prettier
vim.g.format_options_javascriptreact = format_options_prettier
-- formatting with prettier from stdin not working, so use jq for json instead for now in meantime
-- vim.g.format_options_json = utils.merge(format_options_prettier, {parser = "json"}) -- wip: try set parser, nessesary for unsaved buffers
-- NOTE: html seems to work though ?!
vim.g.format_options_json = {}
vim.g.format_options_css = format_options_prettier
vim.g.format_options_scss = format_options_prettier
vim.g.format_options_html = utils.merge(
  format_options_prettier,
  { parser = 'html' }
)
vim.g.format_options_yaml = utils.merge(
  format_options_prettier,
  { parser = 'yaml' }
)
vim.g.format_options_markdown = format_options_prettier

M.formatToggle = function(value)
  local var = format_disabled_var()
  vim.g[var] = utils._if(value ~= nil, value, not vim.g[var])
end

vim.cmd [[command! FormatDisable lua require'lsp.formatting'.formatToggle(true)]]
vim.cmd [[command! FormatEnable lua require'lsp.formatting'.formatToggle(false)]]

-- async buffer formatting:
M.format_async = function()
  if not vim.g[format_disabled_var()] then
    vim.lsp.buf.format(
      utils.merge(vim.g[format_options_var()] or {}, { async = true })
    )
  end
end

-- synchronous version:
M.format_sync = function()
  if not vim.g[format_disabled_var()] then
    vim.lsp.buf.format(vim.g[format_options_var()] or {})
  end
end

return M
