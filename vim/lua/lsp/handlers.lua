-- Write formatting changes to disk after the buffer is updated.
--
-- Otherwise the buffer remains in an unsaved/modified state
vim.lsp.handlers['textDocument/formatting'] = function(err, result, ctx)
  if err ~= nil or result == nil then
    return
  end

  local bufnr = ctx.bufnr
  if not vim.api.nvim_buf_get_option(bufnr, 'modified') then
    local view = vim.fn.winsaveview()
    local client = vim.lsp.get_client_by_id(ctx.client_id)
    local offset_encoding = client.offset_encoding or 'utf-16'

    vim.lsp.util.apply_text_edits(result, bufnr, offset_encoding)
    vim.fn.winrestview(view)

    if bufnr == vim.api.nvim_get_current_buf() then
      vim.cmd [[noautocmd :update]]
      -- TODO: should this refresh gitsigns?
      -- vim.cmd [[GitGutter]]
    end
  end
end

-- TODO: textDocument/hover and textDocument/signatureHelp borders don't seem to
-- be working

-- Add a border around hover (K mapping)
vim.lsp.handlers['textDocument/hover'] = vim.lsp.with(vim.lsp.handlers.hover, {
  border = 'rounded',
})

-- Add a border around signature help (<Leader>+sh mapping)
vim.lsp.handlers['textDocument/signatureHelp'] = vim.lsp.with(
  vim.lsp.handlers.signature_help,
  {
    border = 'rounded',
  }
)

-- default border for diagnostic popups
vim.diagnostic.config {
  float = { border = 'rounded' },
}
