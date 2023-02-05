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
      -- Plugin manager
      use 'wbthomason/packer.nvim'

      -- UI / UX
      use 'nvim-lua/plenary.nvim'
      use 'nvim-lua/popup.nvim'

      -- LSP
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

      -- LSP
      use {
        'jose-elias-alvarez/nvim-lsp-ts-utils',
        requires = {
          'nvim-lua/plenary.nvim',
          'neovim/nvim-lspconfig',
        },
      }

      -- General purpose language server, useful for hooking up prettier/eslint
      use {
        'jose-elias-alvarez/null-ls.nvim',
        requires = {
          'nvim-lua/plenary.nvim',
          'neovim/nvim-lspconfig',
        },
      }

      -- A simple and easy way to use the interface for tree-sitter in Neovim
      -- and to provide some basic functionality such as highlighting based on it
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

      -- Icons for Vim, using patched nerd-font
      use {
        'kyazdani42/nvim-web-devicons',
        config = function()
          require('nvim-web-devicons').setup {
            default = true,
          }
        end,
      }

      -- Git wrapper
      use 'tpope/vim-fugitive'

      -- Remaps . in a way that plugins can tap into it
      use 'tpope/vim-repeat'

      -- Automatically adjusts 'shiftwidth' and 'expandtab' heuristically
      use 'tpope/vim-sleuth'

      -- Provides mappings to easily delete, change and add surroundings in pairs
      use 'tpope/vim-surround'

      -- Highly extendable fuzzy finder over lists
      use {
        'nvim-telescope/telescope.nvim',
        requires = {
          'nvim-lua/plenary.nvim',
          -- NOTE: may need to run 'make' manually in `~.local/share/nvim/site/pack/packer/start/telescope-fzf-native.nvim`
          { 'nvim-telescope/telescope-fzf-native.nvim', run = 'make' },
          'kyazdani42/nvim-web-devicons',
          'nvim-treesitter/nvim-treesitter',
        },
        config = function()
          local actions = require 'telescope.actions'
          require('telescope').setup {
            defaults = {
              -- NOTE: disabled for now, as is breaking the `find_files()` results :-(
              -- selection_strategy = 'row', -- prevents cursor from resetting after removing an item from the list
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
          require('telescope').load_extension 'fzf'
        end,
      }

      -- Reveal the hidden message from Git under the cursor quickly. It shows
      -- the history of commits under the cursor in popup window
      use 'rhysd/git-messenger.vim'

      -- This plugin defines a new text object, based on indentation levels.
      -- This is very useful in languages such as Python, in which the syntax
      -- defines scope in terms of indentation
      use 'michaeljsmith/vim-indent-object'

      -- Set of operator and textobject plugins to add/delete/replace
      -- surroundings of a sandwiched textobject, like (foo), "bar"
      use 'machakann/vim-sandwich'

      -- Switching between a single-line statement and a multi-line one
      use 'AndrewRadev/splitjoin.vim'

      -- Signs for added, removed, and changed lines
      use {
        'lewis6991/gitsigns.nvim',
        requires = {
          'nvim-lua/plenary.nvim',
        },
        config = function()
          require('gitsigns').setup()
        end,
      }

      -- Single tabpage interface for easily cycling through diffs for all
      -- modified files for any git rev
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

      -- File manager for vim/neovim powered by n³
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

      -- Simple zoom window plugin that uses vim's tabs feature to zoom into a
      -- window inspired by ZoomWin plugin
      use {
        'troydm/zoomwintab.vim',
        -- event = {'ZoomWinTabIn', 'ZoomWinTabOut', 'ZoomWinTabToggle'}, -- No such event?
        config = function()
          vim.g.zoomwintab_hidetabbar = false
        end,
      }

      -- Flog is a fast, beautiful, and powerful git branch viewer for Vim
      use 'rbong/vim-flog'

      -- This plugin redefines 6 search commands (/,?,n,N,*,#). At every search
      -- command, it automatically prints> "At match #N out of M matches".
      use 'henrik/vim-indexed-search'

      -- Deleting a buffer in Vim without closing the window
      use {
        'rbgrouleff/bclose.vim',
        -- event = 'Bclose', -- No such event?
      }

      -- Comment out multiple lines with a single keystroke
      use 'scrooloose/nerdcommenter'

      -- Changes the working directory to the project root when you open a file
      -- or directory
      use 'airblade/vim-rooter'

      -- takes the <number> out of <number>w or <number>f{char} by highlighting
      -- all possible choices and allowing you to press one key to jump directly
      -- to the target
      use 'easymotion/vim-easymotion'

      -- Multiple cursors for editing / refactoring text
      use 'mg979/vim-visual-multi'

      -- EditorConfig plugin for Vim
      use 'editorconfig/editorconfig-vim'

      --This project adds eco (embedded coffeescript) support to the vim editor.
      use {
        'AndrewRadev/vim-eco',
        ft = { 'eco' },
      }

      -- Massive (in a good way) Vim plugin for editing Ruby on Rails applications
      use {
        'tpope/vim-rails',
        ft = { 'ruby', 'erb', 'yml' }, -- NOTE: this quite slow on vim startup time, but OK if just for ruby and erb
      }

      -- Additional syntax highlighting that I use for C++11/14/17 development in Vim
      use {
        'octol/vim-cpp-enhanced-highlight',
        ft = { 'cpp', 'c' },
      }

      -- A collection of language packs for Vim.
      -- Seems slow for ruby
      use 'sheerun/vim-polyglot'

      -- Enable syntax highlighting for fastlane configuration files in vim
      use 'milch/vim-fastlane'

      -- Yaml files in vim 7.4 are really slow, due to core yaml syntax. This syntax is simpler/faster.
      use 'stephpy/vim-yaml'

      -- Use the scratch plugin to create a temporary scratch buffer to store
      -- and edit text that will be discarded when you quit/exit vim
      use {
        'vim-scripts/scratch.vim',
        -- event = 'Scratch' -- No such event?
      }

      -- Causes all trailing whitespace characters to be highlighted
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

      -- displays a popup with possible key bindings of the command you started typing
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

      -- A pretty list for showing diagnostics, references, telescope results,
      -- quickfix and location lists to help you solve all the trouble your
      -- code is causing
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

      -- Highlight and search for todo comments like TODO, HACK, BUG in your code base
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

      -- easily browse and preview json files in neovim
      use {
        'gennaro-tedesco/nvim-jqx',
        config = function()
          require('nvim-jqx.config').sort = false
        end,
      }

      -- Preview markdown code directly in your neovim terminal
      use {
        'ellisonleao/glow.nvim',
        -- run this manually for now, after install
        -- run = ":GlowInstall"
      }

      -- A search panel for neovim
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

      -- Lets you freely rearrange your window layouts by letting you move any
      -- window in any direction. Further, it doesn't only let you move around
      -- windows, but also lets you form new columns and rows by moving into
      -- windows horizontally or vertically respectively
      use 'sindrets/winshift.nvim'

      -- Highlight columns in CSV and TSV files and run queries in SQL-like language
      use 'mechatroner/rainbow_csv'

      -- Neat, but has performance issue
      --
      -- Switches to absolute line numbers (:set number norelativenumber)
      -- automatically when relative numbers don't make sense
      -- use 'jeffkreeftmeijer/vim-numbertoggle'

      -- performance issues, disabled:
      --
      -- Show function signature when you type
      -- use 'ray-x/lsp_signature.nvim'

      -- One dark and light colorscheme for neovim
      use { 'navarasu/onedark.nvim' }

      -- Not using for now, as doesn't support TreeSitter syntax as well as OneDark
      --
      -- Dracula for Vim. A dark theme for Vim
      -- use {
      --   'asgeo1/dracula-pro-vim',
      --   as = 'dracula',
      --   config = function()
      --     vim.cmd [[colorscheme dracula_pro]]
      --   end
      -- }

      -- Light-weight and Super Fast statusline plugin. Galaxyline componentizes
      -- Vim's statusline by having a provider for each text area
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
      --
      -- jinja plugins for vim (syntax and indent).
      use 'lepture/vim-jinja'

      -- GitHub Copilot uses OpenAI Codex to suggest code and entire functions
      -- in real-time right from your editor
      use 'github/copilot.vim'
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
