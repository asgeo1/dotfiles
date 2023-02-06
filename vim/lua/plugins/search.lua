return {
  -- A search panel for neovim
  {
    'windwp/nvim-spectre',
    dependencies = {
      'nvim-lua/plenary.nvim',
    },
    keys = {
      {
        '<leader>fp',
        function()
          require('spectre').open { is_close = true }
          -- TODO: enter insert mode
        end,
        desc = 'Search files (Spectre)',
      },
      {
        '<leader>fw',
        "viw:lua require('spectre').open_visual({ is_close = true })<CR>",
        -- function()
        --   require('spectre').open_visual { is_close = true }
        -- end,
        desc = 'Find word under cursor (Spectre)',
      },
    },
    config = function()
      require('spectre').setup {
        mapping = {
          ['open_in_vsplit'] = {
            map = '<c-v>',
            cmd = "<cmd>lua vim.cmd('vsplit ' .. require('spectre.actions').get_current_entry().filename)<CR>",
            desc = 'open in vertical split',
          },
          ['open_in_split'] = {
            map = '<c-s>',
            cmd = "<cmd>lua vim.cmd('split ' .. require('spectre.actions').get_current_entry().filename)<CR>",
            desc = 'open in horizontal split',
          },
          ['open_in_tab'] = {
            map = '<c-t>',
            cmd = "<cmd>lua vim.cmd('tab split ' .. require('spectre.actions').get_current_entry().filename)<CR>",
            desc = 'open in new tab',
          },
        },
      }
    end,
  },

  -- This plugin redefines 6 search commands (/,?,n,N,*,#). At every search
  -- command, it automatically prints> "At match #N out of M matches".
  'henrik/vim-indexed-search',
}
