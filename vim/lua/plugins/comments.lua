return {
  { 'JoosepAlviste/nvim-ts-context-commentstring', lazy = true },

  {
    'echasnovski/mini.comment',
    event = 'VeryLazy',
    opts = {
      hooks = {
        pre = function()
          require('ts_context_commentstring.internal').update_commentstring {}
        end,
      },
    },
    config = function(_, opts)
      require('mini.comment').setup(opts)
    end,
  },

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
