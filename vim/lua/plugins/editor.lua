return {
  -- Changes the working directory to the project root when you open a file
  -- or directory
  'airblade/vim-rooter',

  -- Deleting a buffer without closing the window
  {
    'echasnovski/mini.bufremove',
    version = false,
    keys = {
      {
        '<leader>bd',
        function()
          require('mini.bufremove').delete(0, false)
        end,
        desc = 'Delete buffer',
        silent = true,
      },
      {
        '<leader>bD',
        function()
          require('mini.bufremove').delete(0, true)
        end,
        desc = 'Delete buffer (force)',
        silent = true,
      },
    },
    config = function()
      require('mini.bufremove').setup()
    end,
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

  -- Stack-based window zooming with full layout preservation
  {
    dir = vim.fn.stdpath('config') .. '/lua/zoom-stack',
    name = 'zoom-stack',
    keys = {
      {
        '<C-w>o',
        function() require('zoom-stack').zoom() end,
        desc = 'Zoom current window',
      },
      {
        '<C-w>r',
        function() require('zoom-stack').restore() end,
        desc = 'Restore previous window layout',
      },
    },
    config = function()
      require('zoom-stack').setup({
        keymaps = {
          -- Already defined in keys above, so we can disable here
          zoom = false,
          restore = false,
          toggle = false,
        },
        hide_tabline = false,
      })
    end,
  },

  -- Neat, but has performance issue
  --
  -- Switches to absolute line numbers (:set number norelativenumber)
  -- automatically when relative numbers don't make sense
  -- 'jeffkreeftmeijer/vim-numbertoggle',
}
