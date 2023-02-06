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
    config = function()
      require('which-key').setup {
        -- your configuration comes here
        -- or leave it empty to use the default settings
        -- refer to the configuration section below
      }
    end,
  },
}
