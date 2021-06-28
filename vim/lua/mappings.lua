local map = require "utils".map
local leader = ","

map("n", leader .. "nt", ":NnnPicker<CR>", {silent = true})
map("n", leader .. "nf", ":NnnPicker %:p<CR>", {silent = true})

map("n", "<C-w>O", "<Esc>:ZoomWinTabToggle<CR>")

-- TODO:
-- u (undo)
-- x (delete) are slow!
--
-- add my other mappings in

-- <Plug> not working with lua :-(
-- map("n", leader .. "fw", "<Plug>CtrlSFCwordPath")
-- map("n", leader .. "fp", "<Plug>CtrlSFPrompt")

map("n", leader .. "fp", ":CtrlSF ")

map("n", leader .. "db", ":Bclose<CR>", {silent = true})


-- =============================================================================
-- formatting

-- map("n", "<leader>af", "<cmd>lua vim.lsp.buf.formatting()<CR>")

-- work around, so it can format unsaved buffers. Doesn't seem to work exactly the same as the format-on-save option
map("n", "<leader>af", "<cmd>lua vim.lsp.buf.range_formatting({},{0,0},{vim.fn.line(\"$\")+1,0})<CR>")
-- map("n", "<leader>af", "<cmd>lua require'lsp.formatting'.format()<CR>")

-- =============================================================================
-- autocomplete

local t = function(str)
  return vim.api.nvim_replace_termcodes(str, true, true, true)
end

local check_back_space = function()
  local col = vim.fn.col('.') - 1
  if col == 0 or vim.fn.getline('.'):sub(col, col):match('%s') then
    return true
  else
    return false
  end
end

-- Use (s-)tab to:
--- move to prev/next item in completion menuone
--- jump to prev/next snippet's placeholder
_G.tab_complete = function()
  if vim.fn.pumvisible() == 1 then
    return t "<C-n>"
  elseif check_back_space() then
    return t "<Tab>"
  else
    return vim.fn['compe#complete']()
  end
end

_G.s_tab_complete = function()
  if vim.fn.pumvisible() == 1 then
    return t "<C-p>"
  else
    return t "<S-Tab>"
  end
end

map("i", "<Tab>", "v:lua.tab_complete()", {expr = true})
map("s", "<Tab>", "v:lua.tab_complete()", {expr = true})
map("i", "<S-Tab>", "v:lua.s_tab_complete()", {expr = true})
map("s", "<S-Tab>", "v:lua.s_tab_complete()", {expr = true})


-- =============================================================================
-- Telescope

map("n", leader .. "tf", "<cmd>lua require('telescope.builtin').find_files()<cr>")
map("n", leader .. "tF", "<cmd>lua require('telescope.builtin').git_files()<cr>")
map("n", leader .. "tg", "<cmd>lua require('telescope.builtin').live_grep()<cr>")
map("n", leader .. "ts", "<cmd>lua require('telescope.builtin').grep_string()<cr>")
map("n", leader .. "tS", "<cmd>lua require('telescope.builtin').symbols()<cr>")
map("n", leader .. "tb", "<cmd>lua require('telescope.builtin').buffers()<cr>")
map("n", leader .. "tB", "<cmd>lua require('telescope.builtin').builtin()<cr>")
map("n", leader .. "tr", "<cmd>lua require('telescope.builtin').lsp_references()<cr>")


vim.cmd [[cabbrev nw noautocmd write]]


-- =============================================================================
-- Searching

-- Clear highlights
map("n", leader .. "ch", ":let @/=''<CR> :echo 'Highlights Cleared'<CR>")

-- Don't use vim syntax regexs - use perl/python syntax
map("n", "/", "/\v")
map("v", "/", "/\v")

-- Don't move on *
map("n", "*", "*<c-o>")

-- Substitute
map("n", leader .. "s", ":%s//<left>")



-- =============================================================================
-- indentation
map("n", "<Tab>", ">>")
map("n", "<S-Tab>", "<<")
map("v", "<", "<gv")
map("v", ">", ">gv")
map("v", "<S-Tab>", "<gv")
map("v", "<Tab>", ">gv")

-- adding blank lines
map("n", "BL", "cc<ESC>")
map("n", "BU", "mzO<ESC>`z")
map("n", "BB", "mzo<ESC>`z")

-- remove extraneous / trailing whitespace
map("n", "<F9>", ":StripTrailingWhitespace<CR>:echo 'Extraneous whitespace removed'<CR>", {silent = true})



-- Scroll one line at a time, but keep cursor position relative to the window
-- rather than moving with the line
map("n", "<C-j>", "j<C-e>")
map("n", "<C-k>", "k<C-y>")
