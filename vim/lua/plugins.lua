local on_windows = vim.loop.os_uname().version:match 'Windows'

local function join_paths(...)
  local path_sep = on_windows and '\\' or '/'
  local result = table.concat({ ... }, path_sep)
  return result
end

local fn = vim.fn

local data_path = fn.stdpath 'data' -- OR '/tmp/nvim' if testing/debugging
local pack_path = join_paths(data_path, 'site')
local package_root = join_paths(pack_path, 'pack')
local install_path = join_paths(package_root, 'packer', 'start', 'packer.nvim')
local compile_path = join_paths(install_path, 'plugin', 'packer_compiled.lua')

vim.cmd('set packpath=' .. pack_path)

-- Install packer if not already installed
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

local function load_plugins()
  packer.startup {
    function()
      use 'wbthomason/packer.nvim'

      use 'nvim-lua/plenary.nvim'
      use 'nvim-lua/popup.nvim'

      use 'neovim/nvim-lspconfig'
      use {
        'hrsh7th/nvim-cmp',
        requires = {
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
            ignore_install = { 'haskell', 'phpdoc' }, -- keeps failing to install
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
      use 'tpope/vim-surround'

      use {
        'nvim-telescope/telescope.nvim',
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
        'sindrets/diffview.nvim',
        requires = 'nvim-lua/plenary.nvim',
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

      -- The goal of nvim-bqf is to make Neovim's quickfix window better.
      use {
        'kevinhwang91/nvim-bqf',
        ft = 'qf',
        config = function()
          require('bqf').setup {
            preview = {
              auto_preview = false,
            },
          }
        end,
      }

      use 'mechatroner/rainbow_csv'

      -- Neat, but has performance issue
      -- use 'jeffkreeftmeijer/vim-numbertoggle'

      -- performance issues, disabled:
      -- use 'ray-x/lsp_signature.nvim'

      use { 'navarasu/onedark.nvim' }

      -- Not using for now, as doesn't support TreeSitter syntax as well as OneDark
      -- use {
      --   'asgeo1/dracula-pro-vim',
      --   as = 'dracula',
      --   config = function()
      --     vim.cmd [[colorscheme dracula_pro]]
      --   end
      -- }

      use {
        'NTBBloodbath/galaxyline.nvim',
        setup = function()
          require('onedark').setup {
            style = 'deep',
          }
          require('onedark').load()
        end,
        config = function()
          -- Built-in theme
          require 'galaxyline.themes.eviline'
        end,
        requires = {
          'kyazdani42/nvim-web-devicons',
          'navarasu/onedark.nvim',
        },
      }

      -- For Jinja templates https://jinja.palletsprojects.com/en/3.1.x/
      use 'lepture/vim-jinja'
    end,

    -- Be explicit about where packer packages are installed. This makes it easy
    -- to debug with an alternate location
    config = {
      package_root = package_root,
      compile_path = compile_path,
    },
  }
end

_G.after_packer_complete = function()
  require('lsp').after_packer_complete()
  require('mappings').after_packer_complete()
end

load_plugins()

-- Automatically set up your configuration after cloning packer.nvim
-- Put this at the end after all plugins
if packer_bootstrap then
  packer.sync()
  vim.cmd [[autocmd User PackerComplete ++once lua after_packer_complete()]]
else
  _G.after_packer_complete()
end
