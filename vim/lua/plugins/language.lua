return {
  -- Massive (in a good way) Vim plugin for editing Ruby on Rails applications
  {
    'tpope/vim-rails',
    ft = { 'ruby', 'erb', 'yml' }, -- NOTE: this quite slow on vim startup time, but OK if just for ruby and erb
  },

  -- Additional syntax highlighting that I use for C++11/14/17 development in Vim
  {
    'octol/vim-cpp-enhanced-highlight',
    ft = { 'cpp', 'c' },
  },

  -- A collection of language packs for Vim.
  -- Seems slow for ruby
  'sheerun/vim-polyglot',

  -- Enable syntax highlighting for fastlane configuration files in vim
  'milch/vim-fastlane',

  -- Yaml files in vim 7.4 are really slow, due to core yaml syntax. This syntax is simpler/faster.
  'stephpy/vim-yaml',

  -- This project adds eco (embedded coffeescript) support to the vim editor.
  {
    'AndrewRadev/vim-eco',
    ft = { 'eco' },
  },

  -- Highlight columns in CSV and TSV files and run queries in SQL-like language
  'mechatroner/rainbow_csv',

  -- For Jinja templates https://jinja.palletsprojects.com/en/3.1.x/
  --
  -- jinja plugins for vim (syntax and indent).
  'lepture/vim-jinja',

  -- easily browse and preview json files in neovim
  {
    'gennaro-tedesco/nvim-jqx',
    config = function()
      require('nvim-jqx.config').sort = false
    end,
  },
}
