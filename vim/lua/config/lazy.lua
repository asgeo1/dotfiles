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

vim.api.nvim_create_autocmd('User', {
  pattern = 'LazyDone',
  once = true,
  callback = function()
    require('lsp').after_lazy_done()
    require('config.keymaps').after_lazy_done()
  end,
})

require('lazy').setup {
  spec = {
    { import = 'plugins' },
  },
  defaults = { lazy = false },
  install = { colorscheme = { 'onedark' } },
  checker = {
    -- automatically check for plugin updates
    enabled = true,
    concurrency = nil, ---@type number? set to 1 to check for updates very slowly
    notify = false, -- don't get a notification when new updates are found
    frequency = 3600, -- check for updates every hour
  },
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
