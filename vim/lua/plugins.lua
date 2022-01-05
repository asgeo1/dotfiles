-- install packer
local fn = vim.fn
local install_path = fn.stdpath 'data' .. '/site/pack/packer/start/packer.nvim'
local packer_bootstrap
if fn.empty(fn.glob(install_path)) > 0 then
  packer_bootstrap = fn.system {
    'git',
    'clone',
    '--depth',
    '1',
    'https://github.com/wbthomason/packer.nvim',
    install_path,
  }
end

vim.g.loaded_netrwPlugin = false
vim.cmd [[packadd cfilter]]

-- NOTES:
--
-- Packer plugins are installed into ~/.local/share/nvim/site/pack/packer
-- Packer logfile is here: ~/.cache/nvim/packer.nvim.log
-- packer_compiled.lua is here: ~/.vim/plugin/packer_compiled.vim
--
--
-- If modifying anything in `config` block, then `PackerCompile` is needed
-- before it will take effect

-- TODO: opening ruby files takes ~= 1300ms for some reason, need to work out if there is a way to speed this up

local packer = require 'packer'

packer.startup(function()
  use 'wbthomason/packer.nvim'

  use 'nvim-lua/plenary.nvim'
  use 'nvim-lua/popup.nvim'

  use 'neovim/nvim-lspconfig'
  use {
    'hrsh7th/nvim-cmp',
    requires = {
      'hrsh7th/vim-vsnip',
      'rafamadriz/friendly-snippets',
      'hrsh7th/cmp-vsnip',
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-nvim-lua',
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-path',
      'hrsh7th/cmp-calc',
      'hrsh7th/cmp-emoji',
      'ray-x/cmp-treesitter',
    },
  }

  use {
    'jose-elias-alvarez/nvim-lsp-ts-utils',
    requires = {
      'nvim-lua/plenary.nvim',
      'neovim/nvim-lspconfig',
    },
  }

  -- general purpose language server, useful for hooking up prettier/eslint
  use {
    'jose-elias-alvarez/null-ls.nvim',
    requires = {
      'nvim-lua/plenary.nvim',
      'neovim/nvim-lspconfig',
    },
  }

  use {
    'nvim-treesitter/nvim-treesitter',
    config = function()
      require('nvim-treesitter.configs').setup {
        ensure_installed = 'all',
        ignore_install = { 'haskell' }, -- keeps failing to install
        highlight = {
          enable = true,
          language_tree = true,
        },
        indent = {
          -- Disabled treesitter indentation, as it's super anoying and doesn't seem to work properly
          enable = false,
        },
        refactor = {
          highlight_definitions = {
            enable = true,
          },
        },
        context_commentstring = {
          enable = true,
        },
        textobjects = {
          select = {
            enable = true,
            keymaps = {
              ['af'] = '@function.outer',
              ['if'] = '@function.inner',
              ['ac'] = '@class.outer',
              ['ic'] = '@class.inner',
            },
          },
        },
      }
    end,
    run = ':TSUpdate',
  }
  use 'nvim-treesitter/playground'
  use 'nvim-treesitter/nvim-treesitter-refactor'
  use 'nvim-treesitter/nvim-treesitter-textobjects'
  use 'JoosepAlviste/nvim-ts-context-commentstring'

  use {
    'kyazdani42/nvim-web-devicons',
    config = function()
      require('nvim-web-devicons').setup {
        default = true,
      }
    end,
  }

  use 'tpope/vim-fugitive'
  use 'tpope/vim-repeat'
  use 'tpope/vim-sleuth'

  use {
    -- Use this fork & branch until https://github.com/nvim-telescope/telescope.nvim/pull/1559 is merged
    'Conni2461/telescope.nvim',
    branch = 'fix/selection_strategy_madness',
    requires = {
      'nvim-lua/plenary.nvim',
      'kyazdani42/nvim-web-devicons',
      'nvim-treesitter/nvim-treesitter',
    },
    config = function()
      local actions = require 'telescope.actions'
      require('telescope').setup {
        defaults = {
          selection_strategy = 'row', -- prevents cursor for resetting after removing an item from the list
          file_ignore_patterns = {
            'bower_components',
            'node_modules',
            '.gems',
            'gen/',
            'dist/',
            'packs/',
            'packs-test/',
            'build/',
            'external/',
          },
          mappings = {
            i = {
              ['<C-j>'] = actions.move_selection_next,
              ['<C-k>'] = actions.move_selection_previous,
              ['<C-d>'] = actions.delete_buffer,
            },
          },
        },
      }
    end,
  }

  use 'rhysd/git-messenger.vim'
  use 'michaeljsmith/vim-indent-object'
  use 'machakann/vim-sandwich'
  use 'AndrewRadev/splitjoin.vim'

  -- use fork until https://github.com/glepnir/galaxyline.nvim/pull/154 is merged
  use 'eruizc-dev/galaxyline.nvim'

  use {
    'lewis6991/gitsigns.nvim',
    requires = {
      'nvim-lua/plenary.nvim',
    },
    config = function()
      require('gitsigns').setup()
    end,
  }

  use {
    'mcchrish/nnn.vim',
    config = function()
      require('nnn').setup {
        -- Disable default mappings
        set_default_mappings = false,

        -- specify `TERM` to ensure colors are used
        command = 'TERM=xterm-kitty nnn',

        layout = {
          window = {
            width = 0.9,
            height = 0.6,
            highlight = 'Debug',
          },
        },

        action = {
          ['<c-t>'] = 'tab split',
          ['<c-s>'] = 'split',
          ['<c-v>'] = 'vsplit',
        },
      }
    end,
  }

  use {
    'troydm/zoomwintab.vim',
    -- event = {'ZoomWinTabIn', 'ZoomWinTabOut', 'ZoomWinTabToggle'}, -- No such event?
    config = function()
      vim.g.zoomwintab_hidetabbar = false
    end,
  }

  use 'rbong/vim-flog'
  use 'dyng/ctrlsf.vim'
  use 'henrik/vim-indexed-search'

  use {
    'rbgrouleff/bclose.vim',
    -- event = 'Bclose', -- No such event?
  }

  use 'scrooloose/nerdcommenter'
  use 'airblade/vim-rooter'
  use 'easymotion/vim-easymotion'
  use 'terryma/vim-multiple-cursors'
  use 'editorconfig/editorconfig-vim'

  use {
    'AndrewRadev/vim-eco',
    ft = { 'eco' },
  }

  use {
    'tpope/vim-rails',
    ft = { 'ruby', 'erb', 'yml' }, -- NOTE: this quite slow on vim startup time, but OK if just for ruby and erb
  }

  use {
    'octol/vim-cpp-enhanced-highlight',
    ft = { 'cpp', 'c' },
  }

  -- Seems slow for ruby
  use 'sheerun/vim-polyglot'

  use 'milch/vim-fastlane'

  use 'stephpy/vim-yaml'

  use {
    'vim-scripts/scratch.vim',
    -- event = 'Scratch' -- No such event?
  }

  use {
    'ntpeters/vim-better-whitespace',
    config = function()
      vim.g.strip_whitespace_on_save = 1
      vim.g.better_whitespace_filetypes_blacklist = {
        'spectre_panel',
        'diff',
        'git',
        'gitcommit',
        'unite',
        'qf',
        'help',
        'markdown',
        'fugitive',
      }
      vim.g.strip_whitespace_confirm = 0
      vim.g.show_spaces_that_precede_tabs = 1
      vim.g.better_whitespace_operator = '_s'
      vim.g.strip_only_modified_lines = 1
    end,
  }

  use {
    'folke/which-key.nvim',
    config = function()
      require('which-key').setup {
        -- your configuration comes here
        -- or leave it empty to use the default settings
        -- refer to the configuration section below
      }
    end,
  }

  use {
    'folke/trouble.nvim',
    requires = 'kyazdani42/nvim-web-devicons',
    config = function()
      require('trouble').setup {
        -- your configuration comes here
        -- or leave it empty to use the default settings
        -- refer to the configuration section below
      }
    end,
  }

  use {
    'folke/todo-comments.nvim',
    requires = 'nvim-lua/plenary.nvim',
    config = function()
      require('todo-comments').setup {
        -- your configuration comes here
        -- or leave it empty to use the default settings
        -- refer to the configuration section below
      }
    end,
  }

  use {
    'gennaro-tedesco/nvim-jqx',
    config = function()
      require('nvim-jqx.config').sort = false
    end,
  }

  use {
    'ellisonleao/glow.nvim',
    -- run this manually for now, after install
    -- run = ":GlowInstall"
  }

  use {
    'windwp/nvim-spectre',
    requires = {
      'nvim-lua/plenary.nvim',
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
  }

  use 'kevinhwang91/nvim-bqf'

  use 'mechatroner/rainbow_csv'

  -- Neat, but has performance issue
  -- use 'jeffkreeftmeijer/vim-numbertoggle'

  -- performance issues, disabled:
  -- use 'ray-x/lsp_signature.nvim'

  use {
    'navarasu/onedark.nvim',
    config = function()
      require('onedark').setup {}
      vim.cmd [[colorscheme onedark]]
    end,
  }

  -- Not using for now, as doesn't support TreeSitter syntax as well as OneDark
  -- use {
  --   'asgeo1/dracula-pro-vim',
  --   as = 'dracula',
  --   config = function()
  --     vim.cmd [[colorscheme dracula_pro]]
  --   end
  -- }

  -- Automatically set up your configuration after cloning packer.nvim
  -- Put this at the end after all plugins
  if packer_bootstrap then
    require('packer').sync()
  end
end)
