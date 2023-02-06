return {
  -- Highly extendable fuzzy finder over lists
  {
    'nvim-telescope/telescope.nvim',
    dependencies = {
      'nvim-lua/plenary.nvim',
      -- NOTE: may need to run 'make' manually in `~.local/share/nvim/site/pack/packer/start/telescope-fzf-native.nvim`
      { 'nvim-telescope/telescope-fzf-native.nvim', run = 'make' },
      'kyazdani42/nvim-web-devicons',
      'nvim-treesitter/nvim-treesitter',
    },
    config = function()
      local actions = require 'telescope.actions'
      require('telescope').setup {
        defaults = {
          -- NOTE: disabled for now, as is breaking the `find_files()` results :-(
          -- selection_strategy = 'row', -- prevents cursor from resetting after removing an item from the list
          file_ignore_patterns = {
            'bower_components',
            'node_modules',
            '.gems',
            'gen/',
            'dist/',
            'packs/',
            'packs-test/',
            'build/',
            'external/',
          },
          mappings = {
            i = {
              ['<C-j>'] = actions.move_selection_next,
              ['<C-k>'] = actions.move_selection_previous,
              ['<C-d>'] = actions.delete_buffer,
            },
          },
        },
      }
      require('telescope').load_extension 'fzf'
    end,
  },
}
