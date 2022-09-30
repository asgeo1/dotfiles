local map = require('utils').map
local leader = ','
local M = {}

map('n', leader .. 'nt', ':NnnPicker<CR>', { silent = true })
map('n', leader .. 'nf', ':NnnPicker %:p<CR>', { silent = true })

map('n', '<C-w>O', '<Esc>:ZoomWinTabToggle<CR>')

-- TODO:
--
-- u (undo)
-- x (delete) are slow!

map(
  'n',
  leader .. 'fp',
  "<cmd>lua require('spectre').open({ is_close = true })<CR>i"
)
map(
  'n',
  leader .. 'fw',
  "viw:lua require('spectre').open_visual({ is_close = true })<CR>"
)
map(
  'v',
  leader .. 'fw',
  "<cmd>lua require('spectre').open_visual({ is_close = true })<CR>"
)

map('n', leader .. 'db', ':Bclose<CR>', { silent = true })

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

local feedkey = function(key, mode)
  vim.api.nvim_feedkeys(
    vim.api.nvim_replace_termcodes(key, true, true, true),
    mode,
    true
  )
end

M.after_packer_complete = function()
  local cmp = require 'cmp'
  cmp.setup {
    mapping = {
      -- Disabled for now, finding it a bit anoying
      -- ['<CR>'] = cmp.mapping.confirm { select = true },

      ['<Tab>'] = cmp.mapping(function(fallback)
        if vim.fn.pumvisible() == 1 then
          feedkey('<C-n>', 'n')
        elseif has_words_before() then
          cmp.complete()
        else
          fallback() -- The fallback function sends a already mapped key. In this case, it's probably `<Tab>`.
        end
      end, { 'i', 's' }),

      ['<S-Tab>'] = cmp.mapping(function()
        if vim.fn.pumvisible() == 1 then
          feedkey('<C-p>', 'n')
        end
      end, { 'i', 's' }),
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

map(
  'n',
  leader .. 'tf',
  "<cmd>lua require('telescope.builtin').find_files()<cr>"
)
map(
  'n',
  leader .. 'tF',
  "<cmd>lua require('telescope.builtin').git_files()<cr>"
)
map(
  'n',
  leader .. 'tg',
  "<cmd>lua require('telescope.builtin').live_grep()<cr>"
)
map(
  'n',
  leader .. 'ts',
  "<cmd>lua require('telescope.builtin').grep_string()<cr>"
)
map('n', leader .. 'tS', "<cmd>lua require('telescope.builtin').symbols()<cr>")
map('n', leader .. 'tb', "<cmd>lua require('telescope.builtin').buffers()<cr>")
map('n', leader .. 'tB', "<cmd>lua require('telescope.builtin').builtin()<cr>")
map(
  'n',
  leader .. 'tr',
  "<cmd>lua require('telescope.builtin').lsp_references()<cr>"
)

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
