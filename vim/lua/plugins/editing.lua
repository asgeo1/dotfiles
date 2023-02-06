return {
  {
    'echasnovski/mini.surround',
    keys = function(_plugin, keys)
      -- Populate the keys based on the user's options
      local opts = {
        mappings = {
          add = 'gza', -- Add surrounding in Normal and Visual modes
          delete = 'gzd', -- Delete surrounding
          find = 'gzf', -- Find surrounding (to the right)
          find_left = 'gzF', -- Find surrounding (to the left)
          highlight = 'gzh', -- Highlight surrounding
          replace = 'gzr', -- Replace surrounding
          update_n_lines = 'gzn', -- Update `n_lines`
        },
      }
      local mappings = {
        { opts.mappings.add, desc = 'Add surrounding', mode = { 'n', 'v' } },
        { opts.mappings.delete, desc = 'Delete surrounding' },
        { opts.mappings.find, desc = 'Find right surrounding' },
        { opts.mappings.find_left, desc = 'Find left surrounding' },
        { opts.mappings.highlight, desc = 'Highlight surrounding' },
        { opts.mappings.replace, desc = 'Replace surrounding' },
        {
          opts.mappings.update_n_lines,
          desc = 'Update `MiniSurround.config.n_lines`',
        },
      }
      return vim.list_extend(mappings, keys)
    end,
    opts = {
      mappings = {
        add = 'gza', -- Add surrounding in Normal and Visual modes
        delete = 'gzd', -- Delete surrounding
        find = 'gzf', -- Find surrounding (to the right)
        find_left = 'gzF', -- Find surrounding (to the left)
        highlight = 'gzh', -- Highlight surrounding
        replace = 'gzr', -- Replace surrounding
        update_n_lines = 'gzn', -- Update `n_lines`
      },
    },
    config = function(_, opts)
      -- use gz mappings instead of s to prevent conflict with leap
      require('mini.surround').setup(opts)
    end,
  },

  -- Switching between a single-line statement and a multi-line one
  'AndrewRadev/splitjoin.vim',

  -- This plugin defines a new text object, based on indentation levels.
  -- This is very useful in languages such as Python, in which the syntax
  -- defines scope in terms of indentation
  'michaeljsmith/vim-indent-object',

  -- Multiple cursors for editing / refactoring text
  'mg979/vim-visual-multi',

  -- better text-objects
  {
    'echasnovski/mini.ai',
    -- keys = {
    --   { "a", mode = { "x", "o" } },
    --   { "i", mode = { "x", "o" } },
    -- },
    event = 'VeryLazy',
    dependencies = {
      {
        'nvim-treesitter/nvim-treesitter-textobjects',
        init = function()
          -- no need to load the plugin, since we only need its queries
          require('lazy.core.loader').disable_rtp_plugin 'nvim-treesitter-textobjects'
        end,
      },
    },
    opts = function()
      local ai = require 'mini.ai'
      return {
        n_lines = 500,
        custom_textobjects = {
          o = ai.gen_spec.treesitter({
            a = { '@block.outer', '@conditional.outer', '@loop.outer' },
            i = { '@block.inner', '@conditional.inner', '@loop.inner' },
          }, {}),
          f = ai.gen_spec.treesitter(
            { a = '@function.outer', i = '@function.inner' },
            {}
          ),
          c = ai.gen_spec.treesitter(
            { a = '@class.outer', i = '@class.inner' },
            {}
          ),
        },
      }
    end,
    config = function(_, opts)
      local ai = require 'mini.ai'
      ai.setup(opts)
    end,
  },
}
