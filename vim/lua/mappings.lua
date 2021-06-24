local map = require "utils".map
local leader = ","

map("n", leader .. "nt", ":NnnPicker<CR>", {silent = true})
map("n", leader .. "nf", ":NnnPicker %:p<CR>", {silent = true})

map("n", "<C-w>O", "<Esc>:ZoomWinTabToggle<CR>")

map("n", leader .. "fw", "<Plug>CtrlSFCwordPath")
-- map("n", leader .. "fp", "<Plug>CtrlSFPrompt")  <Plug> not working with lua :-(
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


-- map("n", leader .. leader, ":<C-u>exe v:count ? v:count . 'b' : 'b' . (bufloaded(0) ? '#' : 'n')<CR>")
-- 
-- map("n", leader .. "<C-o>", ":lua require 'buffers'.close_others()<CR>")
-- 
-- map("n", leader .. "q", ":lua require 'buffers'.close()<CR>")
-- map("n", leader .. "w", ":update<CR>")
-- 
-- map("n", leader .. "z", "1z=")
-- 
-- map("n", leader .. "rr", ":%s/\\v()")
-- map("x", leader .. "rr", ":s/\\v%V()")
-- 
-- map("n", leader .. "n", ":e %:h/")
-- 
-- map("n", "/", "<Plug>(incsearch-forward)", {noremap = false})
-- map("n", "?", "<Plug>(incsearch-backward)", {noremap = false})
-- map("n", "n", "<Plug>(incsearch-nohl-n)", {noremap = false})
-- map("n", "N", "<Plug>(incsearch-nohl-N)", {noremap = false})
-- map("n", "*", "<Plug>(incsearch-nohl-*)N", {noremap = false})
-- map("n", "#", "<Plug>(incsearch-nohl-#)", {noremap = false})
-- map("n", "g*", "<Plug>(incsearch-nohl-g*)N", {noremap = false})
-- map("n", "g#", "<Plug>(incsearch-nohl-g#)", {noremap = false})
-- 
-- map("n", "<UP>", ":lua require('lists').move('up')<CR>", {silent = true})
-- map("n", "<DOWN>", ":lua require('lists').move('down')<CR>", {silent = true})
-- map("n", "<LEFT>", ":lua require('lists').move('left')<CR>", {silent = true})
-- map("n", "<RIGHT>", ":lua require('lists').move('right')<CR>", {silent = true})
-- map(
--     "n",
--     leader .. "c",
--     "<Plug>(qf_qf_toggle_stay):lua require('lists').change_active('Quickfix')<CR>",
--     {noremap = false, silent = true}
-- )
-- map(
--     "n",
--     leader .. "v",
--     "<Plug>(qf_loc_toggle_stay):lua require('lists').change_active('Location')<CR>",
--     {noremap = false, silent = true}
-- )
-- map("n", leader .. "b", ":lua require('lists').toggle_active()<CR>")
-- map("n", leader .. "a", ":lua require('lists').change_active('Quickfix')<CR>:Ack<space>")
-- 
-- map("n", "Y", "y$", {noremap = false})
-- map("n", "x", '"_x')
-- map("n", leader .. "o", "o<esc>k")
-- map("n", leader .. "O", "O<esc>j")
-- 
-- map("n", "<C-h>", "<CMD>lua require('Navigator').left()<CR>")
-- map("n", "<C-j>", "<CMD>lua require('Navigator').down()<CR>")
-- map("n", "<C-k>", "<CMD>lua require('Navigator').up()<CR>")
-- map("n", "<C-l>", "<CMD>lua require('Navigator').right()<CR>")
-- 
-- map("n", "<c-w>l", "<c-w>5>")
-- map("n", "<c-w>h", "<c-w>5<")
-- map("n", "<c-w>k", "<c-w>5+")
-- map("n", "<c-w>j", "<c-w>5-")
-- 
-- map({"n", "o", "v"}, "H", "^")
-- map({"n", "o", "v"}, "L", "$")
-- 
-- map({"n", "v"}, "J", "5j")
-- map({"n", "v"}, "K", "5k")
-- 
-- map({"n", "v"}, "j", 'v:count ? (v:count > 5 ? "m\'" . v:count : \'\') . \'j\' : \'gj\'', {expr = true})
-- map({"n", "v"}, "k", 'v:count ? (v:count > 5 ? "m\'" . v:count : \'\') . \'k\' : \'gk\'', {expr = true})
-- 
-- map("", "w", "<Plug>CamelCaseMotion_w", {noremap = false})
-- map("", "b", "<Plug>CamelCaseMotion_b", {noremap = false})
-- map("", "e", "<Plug>CamelCaseMotion_e", {noremap = false})
-- map("", "ge", "<Plug>CamelCaseMotion_ge", {noremap = false})
-- 
-- map("n", "<C-p>", ":lua require('fuzzy').files('')<CR>")
-- map("n", leader .. "gf", ":lua require('fuzzy').git_files()<CR>")
-- map("n", leader .. "n", ":lua require('fuzzy').files(vim.fn.expand('%:h'))<CR>")
-- map("n", leader .. "p", ":Buffers<CR>")
-- map("n", leader .. "<C-p>", ":Commands<CR>")
-- map("n", leader .. "<C-h>", ":Helptags<CR>")
-- map("n", leader .. "m", ":Marks<CR>")
-- map("n", leader .. "f", ":lua require('fuzzy').symbols()<CR>", {silent = true})
-- 
-- map("n", "-", ":Defx -show-ignored-files -search=`expand('%:p')`<CR>")
-- 
-- map(
--     "i",
--     "<CR>",
--     [[pumvisible() ? complete_info()["selected"] != "-1" ? "\<Plug>(completion_confirm_completion)" : "\<c-e>" : lexima#expand('<LT>CR>', 'i')]],
--     {expr = true, noremap = false}
-- )
-- 
-- map("n", "grr", "<Plug>ReplaceWithSameIndentRegisterLine", {noremap = false})
-- map("n", "grR", "<Plug>ReplaceWithRegisterLine", {noremap = false})
-- map("n", "gr", "<Plug>ReplaceWithRegisterOperator", {noremap = false})
-- 
-- map("n", "<CLEAR-1>", "<Plug>UnconditionalPasteLineAfter", {noremap = false})
-- map("n", "<CLEAR-2>", "<Plug>UnconditionalPasteLineBefore", {noremap = false})
-- map("n", "<CLEAR-3>", "<Plug>UnconditionalPasteCommaAfter", {noremap = false})
-- map("n", "<CLEAR-4>", "<Plug>UnconditionalPasteCommaBefore", {noremap = false})
-- map("n", "<CLEAR-5>", "<Plug>UnconditionalPasteCommaSingleQuoteAfter", {noremap = false})
-- map("n", "<CLEAR-6>", "<Plug>UnconditionalPasteCommaSingleQuoteBefore", {noremap = false})
-- map("n", "<CLEAR-7>", "<Plug>VimwikiIncrementListItem", {noremap = false})
-- map("n", "<CLEAR-8>", "<Plug>VimwikiDecrementListItem", {noremap = false})
-- map("n", "glp", "<Plug>UnconditionalPasteIndentedAfter", {noremap = false})
-- map("n", "glP", "<Plug>UnconditionalPasteIndentedBefore", {noremap = false})
-- 
-- map("n", "gco", "m'yyp:Commentary<CR>`'")
-- 
-- map("n", "gj", "<Plug>(GitGutterNextHunk)", {noremap = false})
-- map("n", "gk", "<Plug>(GitGutterPrevHunk)", {noremap = false})
-- map("n", leader .. "gd", ":execute 'Gvdiff ' .. g:git_head<CR>")
-- map("n", leader .. "gr", ":Gread<CR>")
-- map("n", leader .. "gb", ":Gblame<CR>")
-- map("n", leader .. "gs", ":Gstatus<CR><C-w>o")
-- map("n", leader .. "gc", ":BCommits<CR>")
-- map("n", leader .. "gc", ":BCommits<CR>")
-- map("n", leader .. "gm", "<Plug>(git-messenger)", {noremap = false})
-- map("n", leader .. "gu", "<Plug>(GitGutterUndoHunk)", {noremap = false})
-- map("n", leader .. "ga", "<Plug>(GitGutterStageHunk)", {noremap = false})
-- map(
--     "n",
--     leader .. "gg",
--     ":lua require('lists').change_active('Quickfix')<CR>:execute 'VcsJump diff ' .. g:git_head<CR>",
--     {silent = true}
-- )
-- map("n", leader .. "gn", ":lua require('lists').change_active('Quickfix')<CR>:VcsJump merge<CR>")
-- map("n", leader .. "gh", ":diffget //2<CR> :diffupdate<CR>")
-- map("n", leader .. "gl", ":diffget //3<CR> :diffupdate<CR>")
-- 
-- map({"n", "x"}, "s", "<Nope>", {noremap = false})
-- 
-- map({"n", "v"}, "gx", "<Plug>(openbrowser-smart-search)", {noremap = false})
-- 
-- map("n", leader .. "N", ":e %:h/")
-- 
-- map("v", "<", "<gv")
-- map("v", ">", ">gv")
-- map("v", "*", '"vygv:<C-U>/\\<<C-R>v\\><CR>')
-- map("v", "#", '"vygv:<C-U>?\\<<C-R>v\\><CR>')
-- 
-- map("v", "I", "<Plug>(niceblock-I)", {noremap = false})
-- map("v", "gI", "<Plug>(niceblock-gI)", {noremap = false})
-- map("v", "A", "<Plug>(niceblock-A)", {noremap = false})
-- 
-- map("x", "P", [['"_d"'.v:register.'P']], {expr = true})
-- 
-- map("i", "<C-n>", "compe#complete()", {expr = true})
-- map("i", "<CR>", "compe#confirm(lexima#expand('<LT>CR>', 'i'))", {expr = true})
-- map("i", "<C-e>", "compe#close('<C-e>')", {expr = true})
-- 
-- map("c", "<C-J>", "<DOWN>")
-- map("c", "<C-K>", "<UP>")
