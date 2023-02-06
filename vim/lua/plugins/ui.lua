return {
  -- UI / UX
  'nvim-lua/plenary.nvim',
  'nvim-lua/popup.nvim',

  -- Icons for Vim, using patched nerd-font
  {
    'kyazdani42/nvim-web-devicons',
    config = function()
      require('nvim-web-devicons').setup {
        default = true,
      }
    end,
  },

  -- Light-weight and Super Fast statusline plugin. Galaxyline componentizes
  -- Vim's statusline by having a provider for each text area
  {
    'NTBBloodbath/galaxyline.nvim',
    init = function()
      require('onedark').setup {
        style = 'deep',
      }
      require('onedark').load()
    end,
    config = function()
      -- Built-in theme
      require 'galaxyline.themes.eviline'
    end,
    dependencies = {
      'kyazdani42/nvim-web-devicons',
      'navarasu/onedark.nvim',
    },
  },

  -- displays a popup with possible key bindings of the command you started typing
  {
    'folke/which-key.nvim',
    event = 'VeryLazy',
    opts = {
      plugins = { spelling = true },
    },
    config = function(_, opts)
      local wk = require 'which-key'
      wk.setup(opts)
      -- wk.register({
      --   mode = { "n", "v" },
      --   ["g"] = { name = "+goto" },
      --   ["gz"] = { name = "+surround" },
      --   ["]"] = { name = "+next" },
      --   ["["] = { name = "+prev" },
      --   ["<leader><tab>"] = { name = "+tabs" },
      --   ["<leader>b"] = { name = "+buffer" },
      --   ["<leader>c"] = { name = "+code" },
      --   ["<leader>f"] = { name = "+file/find" },
      --   ["<leader>g"] = { name = "+git" },
      --   ["<leader>gh"] = { name = "+hunks" },
      --   ["<leader>q"] = { name = "+quit/session" },
      --   ["<leader>s"] = { name = "+search" },
      --   ["<leader>sn"] = { name = "+noice" },
      --   ["<leader>u"] = { name = "+ui" },
      --   ["<leader>w"] = { name = "+windows" },
      --   ["<leader>x"] = { name = "+diagnostics/quickfix" },
      -- })
    end,
  },
}
