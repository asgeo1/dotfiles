return {
  -- Highly extendable fuzzy finder over lists
  {
    'nvim-telescope/telescope.nvim',
    dependencies = {
      'nvim-lua/plenary.nvim',
      -- NOTE: may need to run 'make' manually in `~/.local/share/nvim/lazy/telescope-fzf-native.nvim`
      { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
      'kyazdani42/nvim-web-devicons',
      'nvim-treesitter/nvim-treesitter',
    },
    keys = {
      {
        '<leader>tf',
        function()
          require('telescope.builtin').find_files()
        end,
        desc = 'Find Files',
      },
      {
        '<leader>tF',
        function()
          require('telescope.builtin').git_files()
        end,
        desc = 'Find Files (version controlled)',
      },
      {
        '<leader>tg',
        function()
          require('telescope.builtin').live_grep()
        end,
        desc = 'Find files by grep',
      },
      {
        '<leader>ts',
        function()
          require('telescope.builtin').grep_string()
        end,
        desc = 'Find word',
      },
      {
        '<leader>tS',
        function()
          require('telescope.builtin').symbols()
        end,
        desc = 'Find symbols',
      },
      {
        '<leader>tb',
        function()
          require('telescope.builtin').buffers()
        end,
        desc = 'Find buffers',
      },
      {
        '<leader>tr',
        function()
          require('telescope.builtin').lsp_references()
        end,
        desc = 'Find LSP references',
      },
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
