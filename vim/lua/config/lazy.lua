-- Installs lazy.nvim if not already installed
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system {
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable', -- latest stable release
    lazypath,
  }
end
vim.opt.rtp:prepend(lazypath)

-- lazy.nvim requires `mapleader` to be set before configuring any plugins
vim.g.mapleader = ','
vim.g.maplocalleader = ','

require('lazy').setup {
  spec = {
    { import = 'plugins' },
  },
  defaults = { lazy = true },
  install = { colorscheme = { 'onedark' } },
  checker = { enabled = true },
  performance = {
    cache = {
      enabled = true,
      -- disable_events = {},
    },
    rtp = {
      disabled_plugins = {
        'gzip',
        'matchit',
        'matchparen',
        'netrwPlugin',
        'rplugin',
        'tarPlugin',
        'tohtml',
        'tutor',
        'zipPlugin',
      },
    },
  },
  debug = false,
}
