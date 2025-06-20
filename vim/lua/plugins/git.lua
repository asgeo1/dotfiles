return {
  -- Modern Git interface for Neovim
  {
    'NeogitOrg/neogit',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'sindrets/diffview.nvim',
      'nvim-telescope/telescope.nvim',
    },
    config = function()
      require('neogit').setup({
        disable_signs = false,
        disable_hint = true,
        disable_context_highlighting = false,
        disable_commit_confirmation = false,
        auto_refresh = true,
        sort_branches = '-committerdate',
        kind = 'tab',
        console_timeout = 2000,
        auto_show_console = true,
        remember_settings = true,
        use_magit_keybindings = false,
        ignored_settings = {},
        -- Override/add mappings
        mappings = {
          -- Modify the default mappings as you see fit
          status = {
            ['cc'] = 'CommitPopup',
            ['s'] = 'Stage',
            ['S'] = 'StageAll',
            ['u'] = 'Unstage',
            ['U'] = 'UnstageAll',
            ['d'] = 'DiffAtFile',
            ['x'] = 'Discard',
            ['X'] = 'DiscardAll',
            ['p'] = 'PullPopup',
            ['P'] = 'PushPopup',
            ['b'] = 'BranchPopup',
            ['?'] = 'HelpPopup',
            ['q'] = 'Close',
          },
        },
        integrations = {
          telescope = true,
          diffview = true,
        },
      })
    end,
    keys = {
      { '<leader>gs', '<cmd>Neogit<cr>', desc = 'Git status' },
      { '<leader>gc', '<cmd>Neogit commit<cr>', desc = 'Git commit' },
      { '<leader>gp', '<cmd>Neogit push<cr>', desc = 'Git push' },
      { '<leader>gP', '<cmd>Neogit pull<cr>', desc = 'Git pull' },
      { '<leader>gb', '<cmd>Neogit branch<cr>', desc = 'Git branch' },
      { '<leader>gl', '<cmd>Neogit log<cr>', desc = 'Git log' },
      { '<leader>gm', function() 
          -- Git blame current line (replaces git-messenger)
          require('gitsigns').blame_line({ full = true })
        end, desc = 'Git blame line' },
    },
  },

  -- Signs for added, removed, and changed lines
  {
    'lewis6991/gitsigns.nvim',
    dependencies = {
      'nvim-lua/plenary.nvim',
    },
    event = 'BufReadPre',
    opts = {
      signs = {
        add = { text = '▎' },
        change = { text = '▎' },
        delete = { text = '契' },
        topdelete = { text = '契' },
        changedelete = { text = '▎' },
        untracked = { text = '▎' },
      },
      on_attach = function(buffer)
        local gs = package.loaded.gitsigns

        local function map(mode, l, r, desc)
          vim.keymap.set(mode, l, r, { buffer = buffer, desc = desc })
        end

        -- stylua: ignore start
        map("n", "]h", gs.next_hunk, "Next Hunk")
        map("n", "[h", gs.prev_hunk, "Prev Hunk")
        map({ "n", "v" }, "<leader>ghs", ":Gitsigns stage_hunk<CR>", "Stage Hunk")
        map({ "n", "v" }, "<leader>ghr", ":Gitsigns reset_hunk<CR>", "Reset Hunk")
        map("n", "<leader>ghS", gs.stage_buffer, "Stage Buffer")
        map("n", "<leader>ghu", gs.undo_stage_hunk, "Undo Stage Hunk")
        map("n", "<leader>ghR", gs.reset_buffer, "Reset Buffer")
        map("n", "<leader>ghp", gs.preview_hunk, "Preview Hunk")
        map("n", "<leader>ghb", function() gs.blame_line({ full = true }) end, "Blame Line")
        map("n", "<leader>ghd", gs.diffthis, "Diff This")
        map("n", "<leader>ghD", function() gs.diffthis("~") end, "Diff This ~")
        map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", "GitSigns Select Hunk")
      end,
    },
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
