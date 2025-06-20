return {
  -- Massive (in a good way) Vim plugin for editing Ruby on Rails applications
  {
    'tpope/vim-rails',
    ft = { 'ruby', 'erb', 'yml' }, -- NOTE: this quite slow on vim startup time, but OK if just for ruby and erb
  },

  -- Tools for tailwindcss in neovim
  {
    'luckasRanarison/tailwind-tools.nvim',
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    opts = {}, -- empty opts is needed at minimum
  },

  -- A collection of language packs for Vim.
  -- Seems slow for ruby
  -- 'sheerun/vim-polyglot',

  -- Enable syntax highlighting for fastlane configuration files in vim
  -- 'milch/vim-fastlane',

  -- -- Yaml files in vim 7.4 are really slow, due to core yaml syntax. This syntax is simpler/faster.
  -- 'stephpy/vim-yaml',

  -- Highlight columns in CSV and TSV files and run queries in SQL-like language
  'mechatroner/rainbow_csv',

  -- easily browse and preview json files in neovim
  -- {
  --   'gennaro-tedesco/nvim-jqx',
  --   config = function()
  --     require('nvim-jqx.config').sort = false
  --   end,
  -- },
}
