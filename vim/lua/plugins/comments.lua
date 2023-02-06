return {
  -- Comment out multiple lines with a single keystroke
  'scrooloose/nerdcommenter',

  -- Highlight and search for todo comments like TODO, HACK, BUG in your code base
  {
    'folke/todo-comments.nvim',
    dependencies = 'nvim-lua/plenary.nvim',
    config = function()
      require('todo-comments').setup {
        -- your configuration comes here
        -- or leave it empty to use the default settings
        -- refer to the configuration section below
      }
    end,
  },
}
