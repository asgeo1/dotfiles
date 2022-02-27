local utils = require 'utils'
local M = {}

local serverity_map = {
  'LspDiagnosticsDefaultError',
  'LspDiagnosticsDefaultWarning',
  'LspDiagnosticsDefaultInformation',
  'LspDiagnosticsDefaultHint',
}

local function source_string(source)
  return string.format('  [%s]', source)
end

-- This is a custom function to help present the diagnostic errors in a nice
-- popup.
--
-- This can be handy, because the default 'virtual_text' can have wrapping and
-- is then hard to read.
--
-- Currently this is mapped to <leader><CR>

M.line_diagnostics = function()
  local width = 70
  local bufnr, lnum = unpack(vim.fn.getcurpos())
  local diagnostics = vim.lsp.diagnostic.get_line_diagnostics(
    bufnr,
    lnum - 1,
    {}
  )
  if vim.tbl_isempty(diagnostics) then
    return
  end

  local lines = {}

  for _, diagnostic in ipairs(diagnostics) do
    table.insert(
      lines,
      ' ■ '
        .. diagnostic.message:gsub('\n', ' ')
        .. source_string(diagnostic.source)
    )
  end

  local floating_bufnr = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(floating_bufnr, 0, -1, false, lines)
  vim.api.nvim_buf_set_option(floating_bufnr, 'filetype', 'diagnosticpopup')

  for i, diagnostic in ipairs(diagnostics) do
    local message_length = #lines[i] - #source_string(diagnostic.source)
    vim.api.nvim_buf_add_highlight(
      floating_bufnr,
      -1,
      serverity_map[diagnostic.severity],
      i - 1,
      0,
      message_length
    )
    vim.api.nvim_buf_add_highlight(
      floating_bufnr,
      -1,
      'DiagnosticSource',
      i - 1,
      message_length,
      -1
    )
  end

  local winnr = vim.api.nvim_open_win(floating_bufnr, false, {
    relative = 'cursor',
    width = width,
    height = #utils.wrap_lines(lines, width - 1),
    row = 1,
    col = 1,
    style = 'minimal',
    border = vim.g.floating_window_border_dark,
  })

  vim.api.nvim_command(
    string.format(
      'autocmd CursorMoved,CursorMovedI,BufHidden,BufLeave,WinScrolled <buffer> ++once lua pcall(vim.api.nvim_win_close, %d, true)',
      winnr
    )
  )
end

return M
