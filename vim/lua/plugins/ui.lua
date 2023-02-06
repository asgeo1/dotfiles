return {
  -- UI / UX
  'nvim-lua/plenary.nvim',
  'nvim-lua/popup.nvim',

  -- ui components
  { 'MunifTanjim/nui.nvim', lazy = true },

  -- Icons for Vim, using patched nerd-font
  {
    'kyazdani42/nvim-web-devicons',
    lazy = true,
    config = function()
      require('nvim-web-devicons').setup {
        default = true,
      }
    end,
  },

  -- Better `vim.notify()`
  {
    'rcarriga/nvim-notify',
    keys = {
      {
        '<leader>un',
        function()
          require('notify').dismiss { silent = true, pending = true }
        end,
        desc = 'Delete all Notifications',
      },
    },
    opts = {
      timeout = 3000,
      max_height = function()
        return math.floor(vim.o.lines * 0.75)
      end,
      max_width = function()
        return math.floor(vim.o.columns * 0.75)
      end,
    },
  },

  -- better vim.ui
  {
    'stevearc/dressing.nvim',
    lazy = true,
    init = function()
      ---@diagnostic disable-next-line: duplicate-set-field
      vim.ui.select = function(...)
        require('lazy').load { plugins = { 'dressing.nvim' } }
        return vim.ui.select(...)
      end
      ---@diagnostic disable-next-line: duplicate-set-field
      vim.ui.input = function(...)
        require('lazy').load { plugins = { 'dressing.nvim' } }
        return vim.ui.input(...)
      end
    end,
  },

  -- bufferline
  {
    'akinsho/bufferline.nvim',
    event = 'VeryLazy',
    opts = {
      options = {
        diagnostics = 'nvim_lsp',
        always_show_bufferline = false,
        diagnostics_indicator = function(_, _, diag)
          local icons = require('lazyvim.config').icons.diagnostics
          local ret = (diag.error and icons.Error .. diag.error .. ' ' or '')
            .. (diag.warning and icons.Warn .. diag.warning or '')
          return vim.trim(ret)
        end,
        offsets = {
          {
            filetype = 'neo-tree',
            text = 'Neo-tree',
            highlight = 'Directory',
            text_align = 'left',
          },
        },
      },
    },
  },

  -- Light-weight and Super Fast statusline plugin. Galaxyline componentizes
  -- Vim's statusline by having a provider for each text area
  {
    'NTBBloodbath/galaxyline.nvim',
    event = 'VeryLazy',
    init = function()
      require('onedark').setup {
        style = 'deep',
      }
      require('onedark').load()
    end,
    config = function()
      -- Built-in theme
      require 'galaxyline.themes.eviline'
    end,
    dependencies = {
      'kyazdani42/nvim-web-devicons',
      'navarasu/onedark.nvim',
    },
  },

  -- noicer ui
  {
    'folke/noice.nvim',
    event = 'VeryLazy',
    opts = {
      lsp = {
        override = {
          ['vim.lsp.util.convert_input_to_markdown_lines'] = true,
          ['vim.lsp.util.stylize_markdown'] = true,
        },
      },
      presets = {
        bottom_search = true,
        command_palette = true,
        long_message_to_split = true,
      },
    },
    -- stylua: ignore
    keys = {
      {
        '<S-Enter>',
        function()
          require('noice').redirect(vim.fn.getcmdline())
        end,
        mode = 'c',
        desc = 'Redirect Cmdline',
      },
      {
        '<leader>snl',
        function()
          require('noice').cmd 'last'
        end,
        desc = 'Noice Last Message',
      },
      {
        '<leader>snh',
        function()
          require('noice').cmd 'history'
        end,
        desc = 'Noice History',
      },
      {
        '<leader>sna',
        function()
          require('noice').cmd 'all'
        end,
        desc = 'Noice All',
      },
      {
        '<c-f>',
        function()
          if not require('noice.lsp').scroll(4) then
            return '<c-f>'
          end
        end,
        silent = true,
        expr = true,
        desc = 'Scroll forward',
        mode = { 'i', 'n', 's' },
      },
      {
        '<c-b>',
        function()
          if not require('noice.lsp').scroll(-4) then
            return '<c-b>'
          end
        end,
        silent = true,
        expr = true,
        desc = 'Scroll backward',
        mode = { 'i', 'n', 's' },
      },
    },
  },

  -- displays a popup with possible key bindings of the command you started typing
  {
    'folke/which-key.nvim',
    event = 'VeryLazy',
    opts = {
      plugins = { spelling = true },
    },
    config = function(_, opts)
      local wk = require 'which-key'
      wk.setup(opts)
      -- wk.register({
      --   mode = { "n", "v" },
      --   ["g"] = { name = "+goto" },
      --   ["gz"] = { name = "+surround" },
      --   ["]"] = { name = "+next" },
      --   ["["] = { name = "+prev" },
      --   ["<leader><tab>"] = { name = "+tabs" },
      --   ["<leader>b"] = { name = "+buffer" },
      --   ["<leader>c"] = { name = "+code" },
      --   ["<leader>f"] = { name = "+file/find" },
      --   ["<leader>g"] = { name = "+git" },
      --   ["<leader>gh"] = { name = "+hunks" },
      --   ["<leader>q"] = { name = "+quit/session" },
      --   ["<leader>s"] = { name = "+search" },
      --   ["<leader>sn"] = { name = "+noice" },
      --   ["<leader>u"] = { name = "+ui" },
      --   ["<leader>w"] = { name = "+windows" },
      --   ["<leader>x"] = { name = "+diagnostics/quickfix" },
      -- })
    end,
  },
}
