local M = {}

-- Function to turn off syntax highlighting and auto commands for the current buffer
function M.TurnOffSyntaxAndAutoCmdsForCurrentBuffer()
  -- Get the current buffer number
  local current_buf = vim.api.nvim_get_current_buf()

  -- Turn off syntax highlighting for the current buffer
  vim.cmd 'syntax clear'
  vim.api.nvim_buf_set_option(current_buf, 'syntax', '')

  -- Disable filetype-based syntax highlighting
  vim.api.nvim_buf_set_option(current_buf, 'filetype', '')

  -- Clear any highlight search settings
  vim.cmd 'nohlsearch'

  -- Clear auto commands specifically for the current buffer
  local buffer_events = { 'BufRead', 'BufWrite', 'BufEnter', 'BufLeave' }
  for _, event in ipairs(buffer_events) do
    vim.cmd('autocmd! ' .. event .. ' <buffer=' .. current_buf .. '>')
  end

  print 'Disabled syntax highlighting and auto commands for the current buffer.'
end

return M
