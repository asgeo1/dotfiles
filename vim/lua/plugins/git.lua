return {
  -- Git wrapper
  'tpope/vim-fugitive',

  -- Reveal the hidden message from Git under the cursor quickly. It shows
  -- the history of commits under the cursor in popup window
  'rhysd/git-messenger.vim',

  -- Signs for added, removed, and changed lines
  {
    'lewis6991/gitsigns.nvim',
    dependencies = {
      'nvim-lua/plenary.nvim',
    },
    config = function()
      require('gitsigns').setup()
    end,
  },

  -- Single tabpage interface for easily cycling through diffs for all
  -- modified files for any git rev
  {
    'sindrets/diffview.nvim',
    dependencies = 'nvim-lua/plenary.nvim',
    config = function()
      require('diffview').setup {
        view = {
          merge_tool = {
            layout = 'diff4_mixed',
          },
        },
        file_history_panel = {
          win_config = {
            position = 'bottom',
            height = 26,
          },
        },
      }
    end,
  },

  -- Flog is a fast, beautiful, and powerful git branch viewer for Vim
  'rbong/vim-flog',
}
