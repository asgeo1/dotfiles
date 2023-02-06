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
      }
    end,
    run = ':TSUpdate',
  },
  'nvim-treesitter/playground',
  'nvim-treesitter/nvim-treesitter-refactor',
  'nvim-treesitter/nvim-treesitter-textobjects',
  'JoosepAlviste/nvim-ts-context-commentstring',
}
