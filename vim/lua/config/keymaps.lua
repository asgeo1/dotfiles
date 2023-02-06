local map = require('util.utils').map
local leader = ','
local M = {}

-- TODO:
--
-- u (undo)
-- x (delete) are slow!

-- =============================================================================
-- autocomplete

local has_words_before = function()
  if vim.api.nvim_buf_get_option(0, 'buftype') == 'prompt' then
    return false
  end
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  return col ~= 0
    and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]
        :sub(col, col)
        :match '%s'
      == nil
end

M.after_lazy_done = function()
  local cmp = require 'cmp'
  cmp.setup {
    mapping = {
      ['<C-Space>'] = cmp.mapping.confirm {
        behavior = cmp.ConfirmBehavior.Insert,
        select = true,
      },

      ['<C-n>'] = function(fallback)
        if not cmp.select_next_item() then
          if vim.bo.buftype ~= 'prompt' and has_words_before() then
            cmp.complete()
          else
            fallback()
          end
        end
      end,

      ['<C-p>'] = function(fallback)
        if not cmp.select_prev_item() then
          if vim.bo.buftype ~= 'prompt' and has_words_before() then
            cmp.complete()
          else
            fallback()
          end
        end
      end,
    },
    sources = {
      { name = 'nvim_lsp' },
      { name = 'buffer' },
      { name = 'path' },
      { name = 'nvim_lua' },
      { name = 'calc' },
      { name = 'emoji' },
      { name = 'treesitter' },
    },
  }
end

-- =============================================================================
-- Telescope

-- Not sure what this is for?
vim.cmd [[cabbrev nw noautocmd write]]

-- =============================================================================
-- Searching

-- Clear highlights
map('n', leader .. 'ch', ":let @/=''<CR> :echo 'Highlights Cleared'<CR>")

-- Don't use vim syntax regexs - use perl/python syntax
-- (not working)
-- map("n", "/", "/\v")
-- map("v", "/", "/\v")

-- Don't move on *
-- (not working)
-- map("n", "*", "*<c-o>")

-- Substitute
map('n', leader .. 's', ':%s//<left>')

-- =============================================================================
-- indentation
-- NOTE: don't use <Tab> for indentation anymore, as this breaks "jump forward", i.e. <CTRL+i>, because in a terminal <CTRL+i> is the same as <Tab>
-- map("n", "<Tab>", ">>")
-- map("n", "<S-Tab>", "<<")
-- map("v", "<S-Tab>", "<gv")
-- map("v", "<Tab>", ">gv")
map('v', '<', '<gv')
map('v', '>', '>gv')

-- adding blank lines
map('n', 'BL', 'cc<ESC>')
map('n', 'BU', 'mzO<ESC>`z')
map('n', 'BB', 'mzo<ESC>`z')

-- remove extraneous / trailing whitespace
map(
  'n',
  '<F9>',
  ":StripTrailingWhitespace<CR>:echo 'Extraneous whitespace removed'<CR>",
  { silent = true }
)

-- Scroll one line at a time, but keep cursor position relative to the window
-- rather than moving with the line
map('n', '<C-j>', 'j<C-e>')
map('n', '<C-k>', 'k<C-y>')

-- up/down movement now works on wrapped lines
map('n', 'j', 'gj')
map('n', 'k', 'gk')

-- Neovim 0.6 new default mapping for 'Y' annoys me, remove it
vim.api.nvim_del_keymap('n', 'Y')

return M
