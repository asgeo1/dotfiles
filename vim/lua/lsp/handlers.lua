-- Disabled for now, as throwing errors
--
-- vim.lsp.handlers["textDocument/formatting"] = function(err, _, result, _, bufnr)
--   if err ~= nil or result == nil then
--     return
--   end
--
--   if not vim.api.nvim_buf_get_option(bufnr, "modified") then
--     local view = vim.fn.winsaveview()
--
--     vim.lsp.util.apply_text_edits(result, bufnr)
--     vim.fn.winrestview(view)
--
--     if bufnr == vim.api.nvim_get_current_buf() then
--       vim.cmd [[noautocmd :update]]
--       -- TODO: should this refresh gitsigns?
--       -- vim.cmd [[GitGutter]]
--     end
--   end
-- end


-- Configure how diagnostics will present in the UI
vim.lsp.handlers["textDocument/publishDiagnostics"] = function(...)
  vim.lsp.with(
    vim.lsp.diagnostic.on_publish_diagnostics,
    {
      virtual_text = false,     -- show virtual text to the right of the line
      underline = true,         -- underline the specific code causing the issue
      signs = true,             -- put an error sign in the gutter
      update_in_insert = false  -- don't update diagnostics in insert mode (doesn't apply to status-line, that will get updated regardless)
    }
  )(...)
end


-- Add a border around hover (K mapping)
vim.lsp.handlers["textDocument/hover"] =
  vim.lsp.with(
  vim.lsp.handlers.hover,
  {
    border = vim.g.floating_window_border_dark
  }
)


-- Add a border around signature help (<Leader>+sh mapping)
vim.lsp.handlers["textDocument/signatureHelp"] =
  vim.lsp.with(
  vim.lsp.handlers.signature_help,
  {
    border = vim.g.floating_window_border_dark
  }
)
