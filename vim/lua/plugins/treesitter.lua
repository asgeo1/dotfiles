return {
  -- A simple and easy way to use the interface for tree-sitter in Neovim
  -- and to provide some basic functionality such as highlighting based on it
  {
    'nvim-treesitter/nvim-treesitter',
    config = function()
      require('nvim-treesitter.configs').setup {
        ensure_installed = 'all',
        ignore_install = { 'haskell', 'phpdoc' }, -- keeps failing to install
        highlight = {
          enable = true,
          language_tree = true,
        },
        indent = {
          -- Disabled treesitter indentation, as it's super anoying and doesn't seem to work properly
          enable = false,
        },
        refactor = {
          highlight_definitions = {
            enable = true,
          },
        },
        context_commentstring = {
          enable = true,
        },
        textobjects = {
          select = {
            enable = true,
            keymaps = {
              ['af'] = '@function.outer',
              ['if'] = '@function.inner',
              ['ac'] = '@class.outer',
              ['ic'] = '@class.inner',
            },
          },
        },

        playground = {
          enable = true,
          disable = {},
          updatetime = 25, -- Debounced time for highlighting nodes in the playground from source code
          persist_queries = false, -- Whether the query persists across vim sessions
          keybindings = {
            toggle_query_editor = 'o',
            toggle_hl_groups = 'i',
            toggle_injected_languages = 't',
            toggle_anonymous_nodes = 'a',
            toggle_language_display = 'I',
            focus_language = 'f',
            unfocus_language = 'F',
            update = 'R',
            goto_node = '<cr>',
            show_help = '?',
          },
        },
      }
    end,
    build = ':TSUpdate',
    event = 'BufReadPost',
  },
  'nvim-treesitter/nvim-treesitter-refactor',

  -- useful for testing treesitter queries
  'nvim-treesitter/playground',
}
