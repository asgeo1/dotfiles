return {
  -- UI / UX
  {
    'nvim-lua/popup.nvim',
    dependencies = 'nvim-lua/plenary.nvim',
    lazy = true,
  },

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

  -- This is anoying, because it keeps obscuring code and getting in the way
  --
  -- Better `vim.notify()`
  -- {
  --   'rcarriga/nvim-notify',
  --   keys = {
  --     {
  --       '<leader>un',
  --       function()
  --         require('notify').dismiss { silent = true, pending = true }
  --       end,
  --       desc = 'Delete all Notifications',
  --     },
  --   },
  --   opts = {
  --     timeout = 3000,
  --     max_height = function()
  --       return math.floor(vim.o.lines * 0.75)
  --     end,
  --     max_width = function()
  --       return math.floor(vim.o.columns * 0.75)
  --     end,
  --   },
  -- },

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

      local condition = require 'galaxyline.condition'
      local colors = require('galaxyline.themes.colors')['doom-one']

      -- Replace FileName with FilePath for section 5
      require('galaxyline').section.left[5] = {
        FileName = {
          provider = 'FilePath',
          condition = condition.buffer_not_empty,
          highlight = { colors.magenta, colors.bg, 'bold' },
        },
      }
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

  -- dashboard
  {
    'goolord/alpha-nvim',
    event = 'VimEnter',
    opts = function()
      local dashboard = require 'alpha.themes.dashboard'
      local logo = [[
      ██╗      █████╗ ███████╗██╗   ██╗██╗   ██╗██╗███╗   ███╗          Z
      ██║     ██╔══██╗╚══███╔╝╚██╗ ██╔╝██║   ██║██║████╗ ████║      Z
      ██║     ███████║  ███╔╝  ╚████╔╝ ██║   ██║██║██╔████╔██║   z
      ██║     ██╔══██║ ███╔╝    ╚██╔╝  ╚██╗ ██╔╝██║██║╚██╔╝██║ z
      ███████╗██║  ██║███████╗   ██║    ╚████╔╝ ██║██║ ╚═╝ ██║
      ╚══════╝╚═╝  ╚═╝╚══════╝   ╚═╝     ╚═══╝  ╚═╝╚═╝     ╚═╝
      ]]

      dashboard.section.header.val = vim.split(logo, '\n')
      dashboard.section.buttons.val = {
        dashboard.button(
          'f',
          ' ' .. ' Find file',
          ':Telescope find_files <CR>'
        ),
        dashboard.button(
          'n',
          ' ' .. ' New file',
          ':ene <BAR> startinsert <CR>'
        ),
        dashboard.button(
          'r',
          ' ' .. ' Recent files',
          ':Telescope oldfiles <CR>'
        ),
        dashboard.button(
          'g',
          ' ' .. ' Find text',
          ':Telescope live_grep <CR>'
        ),
        dashboard.button('c', ' ' .. ' Config', ':e $MYVIMRC <CR>'),
        dashboard.button(
          's',
          '勒' .. ' Restore Session',
          [[:lua require("persistence").load() <cr>]]
        ),
        dashboard.button('l', '鈴' .. ' Lazy', ':Lazy<CR>'),
        dashboard.button('q', ' ' .. ' Quit', ':qa<CR>'),
      }
      for _, button in ipairs(dashboard.section.buttons.val) do
        button.opts.hl = 'AlphaButtons'
        button.opts.hl_shortcut = 'AlphaShortcut'
      end
      dashboard.section.footer.opts.hl = 'Type'
      dashboard.section.header.opts.hl = 'AlphaHeader'
      dashboard.section.buttons.opts.hl = 'AlphaButtons'
      dashboard.opts.layout[1].val = 8
      return dashboard
    end,
    config = function(_, dashboard)
      vim.b.miniindentscope_disable = true

      -- close Lazy and re-open when the dashboard is ready
      if vim.o.filetype == 'lazy' then
        vim.cmd.close()
        vim.api.nvim_create_autocmd('User', {
          pattern = 'AlphaReady',
          callback = function()
            require('lazy').show()
          end,
        })
      end

      require('alpha').setup(dashboard.opts)

      vim.api.nvim_create_autocmd('User', {
        pattern = 'LazyVimStarted',
        callback = function()
          local stats = require('lazy').stats()
          local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)
          dashboard.section.footer.val = '⚡ Neovim loaded '
            .. stats.count
            .. ' plugins in '
            .. ms
            .. 'ms'
          pcall(vim.cmd.AlphaRedraw)
        end,
      })
    end,
  },
}
