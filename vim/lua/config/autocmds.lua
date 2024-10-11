-- Packer
--
-- vim.cmd [[augroup Autogroup]]
-- Automatically run PackerCompile when plugins.lua is modified
-- vim.cmd [[autocmd BufWritePost plugins.lua PackerCompile]]
-- vim.cmd [[autocmd User PackerComplete,PackerCompileDone lua require("indent_blankline.utils").reset_highlights()]]
-- vim.cmd [[augroup END]]

-- vim-flog
vim.cmd [[augroup myfloggroup]]
-- use `q` to quit, rather than `gq`
vim.cmd [[autocmd FileType floggraph map <buffer> <silent> q <Plug>(FlogQuit)]]
-- not working:
vim.cmd [[autocmd FileType floggraph let b:strip_trailing_whitespace_enabled=0]]
vim.cmd [[augroup END]]

vim.cmd [[augroup custom_ruby_syntax]]
vim.cmd 'autocmd BufNewFile,BufRead *.rbi set syntax=ruby'
vim.cmd 'autocmd BufNewFile,BufRead *.rbi set filetype=ruby'
vim.cmd 'autocmd BufNewFile,BufRead *.env.* set filetype=sh'
vim.cmd [[augroup END]]

vim.cmd [[augroup custom_perl_settings]]
vim.cmd 'autocmd FileType perl setlocal iskeyword+=\\$'
vim.cmd [[augroup END]]
