return {
  -- Comment out multiple lines with a single keystroke
  'scrooloose/nerdcommenter',

  -- Highlight and search for todo comments like TODO, HACK, BUG in your code base
  {
    'folke/todo-comments.nvim',
    dependencies = 'nvim-lua/plenary.nvim',
    cmd = { 'TodoTrouble', 'TodoTelescope' },
    event = 'BufReadPost',
    config = true,
    -- stylua: ignore
    keys = {
      {
        ']t',
        function()
          require('todo-comments').jump_next()
        end,
        desc = 'Next todo comment',
      },
      {
        '[t',
        function()
          require('todo-comments').jump_prev()
        end,
        desc = 'Previous todo comment',
      },
      { '<leader>xt', '<cmd>TodoTrouble<cr>', desc = 'Todo (Trouble)' },
      {
        '<leader>xT',
        '<cmd>TodoTrouble keywords=TODO,FIX,FIXME<cr>',
        desc = 'Todo/Fix/Fixme (Trouble)',
      },
      { '<leader>st', '<cmd>TodoTelescope<cr>', desc = 'Todo' },
    },
  },
}
