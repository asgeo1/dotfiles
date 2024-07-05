return {
  -- Changes the working directory to the project root when you open a file
  -- or directory
  'airblade/vim-rooter',

  -- Deleting a buffer in Vim without closing the window
  {
    'rbgrouleff/bclose.vim',
    keys = {
      {
        '<leader>bd',
        ':Bclose<CR>',
        desc = 'Delete buffer',
        silent = true,
      },
    },
    -- event = 'Bclose', -- No such event?
  },

  -- The goal of nvim-bqf is to make Neovim's quickfix window better.
  {
    'kevinhwang91/nvim-bqf',
    ft = 'qf',
    config = function()
      require('bqf').setup {
        preview = {
          auto_preview = false,
        },
      }
    end,
  },

  -- Preview markdown code directly in your neovim terminal
  {
    'ellisonleao/glow.nvim',
    -- run this manually for now, after install
    -- run = ":GlowInstall"
  },

  -- Lets you freely rearrange your window layouts by letting you move any
  -- window in any direction. Further, it doesn't only let you move around
  -- windows, but also lets you form new columns and rows by moving into
  -- windows horizontally or vertically respectively
  'sindrets/winshift.nvim',

  -- A pretty list for showing diagnostics, references, telescope results,
  -- quickfix and location lists to help you solve all the trouble your
  -- code is causing
  {
    'folke/trouble.nvim',
    dependencies = 'kyazdani42/nvim-web-devicons',
    cmd = { 'TroubleToggle', 'Trouble' },
    opts = { use_diagnostic_signs = true },
    keys = {
      {
        '<leader>xx',
        '<cmd>Trouble diagnostics toggle<cr>',
        desc = 'Document Diagnostics (Trouble)',
      },
      {
        '<leader>xX',
        '<cmd>Trouble diagnostics toggle filter.buf=0<cr>',
        desc = 'Buffer Diagnostics (Trouble)',
      },
      {
        '<leader>cs',
        '<cmd>Trouble symbols toggle focus=false<cr>',
        desc = 'Symbols (Trouble)',
      },
      {
        '<leader>cl',
        '<cmd>Trouble lsp toggle focus=false win.position=right<cr>',
        desc = 'LSP Definitions / references / ... (Trouble)',
      },
      {
        '<leader>xL',
        '<cmd>Trouble loclist toggle<cr>',
        desc = 'Location List (Trouble)',
      },
      {
        '<leader>xQ',
        '<cmd>Trouble qflist toggle<cr>',
        desc = 'Quickfix List (Trouble)',
      },
    },
  },

  -- Simple zoom window plugin that uses vim's tabs feature to zoom into a  -- window inspired by ZoomWin plugin
  {
    'troydm/zoomwintab.vim',
    keys = {
      {
        '<C-w>O',
        '<Esc>:ZoomWinTabToggle<CR>',
        desc = 'Zoom window',
      },
    },
    -- event = {'ZoomWinTabIn', 'ZoomWinTabOut', 'ZoomWinTabToggle'}, -- No such event?
    config = function()
      vim.g.zoomwintab_hidetabbar = false
    end,
  },

  -- Neat, but has performance issue
  --
  -- Switches to absolute line numbers (:set number norelativenumber)
  -- automatically when relative numbers don't make sense
  -- 'jeffkreeftmeijer/vim-numbertoggle',
}
