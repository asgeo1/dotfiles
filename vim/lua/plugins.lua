vim.g.loaded_netrwPlugin = false
vim.cmd [[packadd cfilter]]


-- TODO: opening ruby files takes ~= 1300ms for some reason, need to work out if there is a way to speed this up

local packer = require'packer'

packer.init({
  compile_on_sync = false -- Don't generate .vim/plugin/packer_compiled.vim, as this is very slow for 'x' and 'u' commands, and seems to break treesitter highlighting
})

packer.startup(
    function()
        use "wbthomason/packer.nvim"

        use "neovim/nvim-lspconfig"
        use {
            "hrsh7th/nvim-compe",
            setup = require("compe").setup {
            -- enabled = true,
            -- debug = false,
            -- autocomplete = false,
            -- min_length = 1,
            -- preselect = "disable",
            -- allow_prefix_unmatch = false,
            enabled = true,
            autocomplete = true,
            debug = false,
            min_length = 1,
            preselect = 'enable',
            throttle_time = 80,
            source_timeout = 200,
            incomplete_delay = 400,
            max_abbr_width = 100,
            max_kind_width = 100,
            max_menu_width = 100,
            documentation = true,
            source = {
              path = true,
              buffer = true,
              nvim_lsp = true,
              nvim_lua = true,
              calc = true,
              emoji = true,
              treesitter = true
            }
          }
        }
        use "jose-elias-alvarez/nvim-lsp-ts-utils"

        use {
            "nvim-treesitter/nvim-treesitter",
            run = ":TSUpdate",
            config = function()
              vim.wo.foldmethod = "expr"
              vim.wo.foldexpr = "nvim_treesitter#foldexpr()"
            end
        }
        use "nvim-treesitter/playground"
        use "nvim-treesitter/nvim-treesitter-refactor"
        use "nvim-treesitter/nvim-treesitter-textobjects"
        use "JoosepAlviste/nvim-ts-context-commentstring"
        use "windwp/nvim-ts-autotag"

        use {
          "navarasu/onedark.nvim",
          --"monsonjeremy/onedark.nvim",
          setup = require("onedark").setup {}
        }

        use {
          'asgeo1/dracula-pro-vim',
          as = 'dracula',
          config = function()
            vim.g.dracula_colorterm = true -- Include background fill colors
          end
        }

        use {
            "kyazdani42/nvim-web-devicons",
            setup = require("nvim-web-devicons").setup {
              default = true
            }
        }

        use "tpope/vim-commentary" -- comments
        use "tpope/vim-fugitive" -- git integration
        use "tpope/vim-repeat" -- mappings for repeating keystrokes
        use "tpope/vim-sleuth" -- indentation

        use {
          "airblade/vim-gitgutter",
          config = function()
            vim.g.gitgutter_map_keys = false
            vim.g.gitgutter_sign_added = "│"
            vim.g.gitgutter_sign_modified = "│"
            vim.g.gitgutter_sign_removed = "│"
            vim.g.gitgutter_sign_removed_first_line = "│"
            vim.g.gitgutter_sign_removed_above_and_below = "│"
            vim.g.gitgutter_sign_modified_removed = "│"

            -- my settings
            vim.g.gitgutter_eager = false
            vim.g.gitgutter_realtime = false
            vim.g.gitgutter_git_executable = 'git'

            -- fix issue with background color of gitgutter signs
            -- vim.highlight GitGutterAdd          guifg=#009900 guibg=NONE ctermfg=2 ctermbg=0
            -- vim.highlight GitGutterChange       guifg=#bbbb00 guibg=NONE ctermfg=3 ctermbg=0
            -- vim.highlight GitGutterDelete       guifg=#ff2222 guibg=NONE ctermfg=1 ctermbg=0
          end
        }

        use "nvim-lua/plenary.nvim"
        use "nvim-lua/popup.nvim"
        use "nvim-telescope/telescope.nvim"

        use {
            "rhysd/git-messenger.vim",
            config = function()
                vim.g.git_messenger_floating_win_opts = {border = vim.g.floating_window_border_dark}
            end
        }

        -- use {
        --     "Shougo/defx.nvim",
        --     run = ":UpdateRemotePlugins",
        --     requires = {
        --         {"kristijanhusak/defx-git"},
        --         {"kristijanhusak/defx-icons"}
        --     },
        --     config = function()
        --         vim.g.defx_icons_root_opened_tree_icon = "├"
        --         vim.g.defx_icons_nested_opened_tree_icon = "├"
        --         vim.g.defx_icons_nested_closed_tree_icon = "│"
        --         vim.g.defx_icons_directory_icon = "│"
        --         vim.g.defx_icons_parent_icon = "├"

        --         vim.fn["defx#custom#column"](
        --             "mark",
        --             {
        --                 ["readonly_icon"] = "◆",
        --                 ["selected_icon"] = "■"
        --             }
        --         )

        --         vim.fn["defx#custom#column"](
        --             "indent",
        --             {
        --                 ["indent"] = "    "
        --             }
        --         )

        --         vim.fn["defx#custom#option"](
        --             "_",
        --             {
        --                 ["columns"] = "indent:mark:icons:git:filename"
        --             }
        --         )

        --         vim.fn["defx#custom#column"](
        --             "git",
        --             "indicators",
        --             {
        --                 ["Modified"] = "◉",
        --                 ["Staged"] = "✚",
        --                 ["Untracked"] = "◈",
        --                 ["Renamed"] = "➜",
        --                 ["Unmerged"] = "═",
        --                 ["Ignored"] = "▨",
        --                 ["Deleted"] = "✖",
        --                 ["Unknown"] = "?"
        --             }
        --         )
        --     end
        -- }

        use "michaeljsmith/vim-indent-object"
        use "wellle/targets.vim"

        use "vim-scripts/UnconditionalPaste"

        -- use {
        --     "haya14busa/incsearch.vim",
        --     config = function()
        --         vim.g["incsearch#auto_nohlsearch"] = true
        --         vim.g["incsearch#magic"] = "\\v"
        --         vim.g["incsearch#consistent_n_direction"] = true
        --         vim.g["incsearch#do_not_save_error_message_history"] = true
        --     end
        -- }

        -- use {
        --     "mileszs/ack.vim",
        --     config = function()
        --         vim.g.ackprg = "rg --vimgrep --no-heading --hidden --smart-case"
        --     end
        -- }

        use "machakann/vim-sandwich"

        -- use {
        --     "vimwiki/vimwiki",
        --     branch = "dev",
        --     requires = {{"inkarkat/vim-SyntaxRange"}},
        --     config = function()
        --         vim.g.vimwiki_list = {
        --             {
        --                 path = "~/vimwiki/",
        --                 auto_tags = 1,
        --                 auto_generate_links = 1,
        --                 auto_generate_tags = 1,
        --                 links_space_char = "-"
        --             }
        --         }
        --         vim.g.vimwiki_folding = "custom"
        --         vim.g.vimwiki_use_calendar = 0
        --         vim.g.vimwiki_global_ext = 0
        --         vim.g.vimwiki_valid_html_tags = "b,i,s,u,sub,sup,kbd,br,hr,span"

        --         vim.g.vimwiki_key_mappings = {
        --             all_maps = 1,
        --             global = 0,
        --             headers = 0,
        --             text_objs = 1,
        --             table_format = 0,
        --             table_mappings = 1,
        --             lists = 1,
        --             links = 0,
        --             html = 0,
        --             mouse = 1
        --         }
        --     end
        -- }

        use {
            "AndrewRadev/splitjoin.vim",
            config = function()
                vim.g.conjoin_map_J = "gJ"
                vim.g.conjoin_map_gJ = "<con-nope>"
            end
        }

        use "glepnir/galaxyline.nvim"

        use {
          'mcchrish/nnn.vim',
          setup = require("nnn").setup {
            -- Disable default mappings
            set_default_mappings = false,

            -- specify `TERM` to ensure colors are used
            command = "TERM=xterm-kitty nnn",

            layout = {
              window = {
                width = 0.9,
                height = 0.6,
                highlight = 'Debug'
              }
            },

            action = {
              ['<c-t>'] = 'tab split',
              ['<c-s>'] = 'split',
              ['<c-v>'] = 'vsplit'
            }
          }
        }

        use {
          'troydm/zoomwintab.vim',
          -- event = {'ZoomWinTabIn', 'ZoomWinTabOut', 'ZoomWinTabToggle'}, -- No such event?
          config = function()
            vim.g.zoomwintab_hidetabbar = false
          end
        }

        use 'rbong/vim-flog' -- (git browser)

        use {
          'dyng/ctrlsf.vim',
          config = function()
            vim.g.ctrlsf_ignore_dir = {'bower_components', 'node_modules', '.gems', 'gen', 'dist', 'packs', 'packs-test', 'build', 'external'}
            vim.g.ctrlsf_auto_close = false
          end
        }

        use 'henrik/vim-indexed-search'

        use {
          'rbgrouleff/bclose.vim',
          -- event = 'Bclose', -- No such event?
          config = function()
            vim.g.bclose_no_plugin_maps = true
          end
        }

        use 'scrooloose/nerdcommenter'

        use {
          'airblade/vim-rooter',
          config = function()
            vim.g.rooter_patterns = {'.git', '.git/', '_darcs/', '.hg/', '.bzr/', '.svn/'}
            vim.g.rooter_silent_chdir = true
          end
        }

        use 'easymotion/vim-easymotion'

        use {
          'terryma/vim-multiple-cursors',
          config = function()
            vim.g.multi_cursor_use_default_mapping = false

            -- Default mapping
            vim.g.multi_cursor_start_word_key      = '<C-n>'
            vim.g.multi_cursor_select_all_word_key = '<C-a>'
            vim.g.multi_cursor_start_key           = 'g<C-n>'
            vim.g.multi_cursor_select_all_key      = 'g<C-a>'
            vim.g.multi_cursor_next_key            = '<C-n>'
            vim.g.multi_cursor_prev_key            = '<C-p>'
            vim.g.multi_cursor_skip_key            = '<C-x>'
            vim.g.multi_cursor_quit_key            = '<Esc>'
          end
        }

        use 'editorconfig/editorconfig-vim'

        use {
          'AndrewRadev/vim-eco',
          ft = { 'eco' }
        }

        use {
          'tpope/vim-rails',
          ft = { 'ruby', 'erb', 'yml' }  -- NOTE: this quite slow on vim startup time, but OK if just for ruby and erb
        }

        use {
          'octol/vim-cpp-enhanced-highlight',
          ft = { 'cpp', 'c' }
        }

        -- Seems slow for ruby
        use 'sheerun/vim-polyglot'

        use 'milch/vim-fastlane'

        use 'stephpy/vim-yaml'

        use {
          'vim-scripts/scratch.vim',
          -- event = 'Scratch' -- No such event?
        }

        use 'axelf4/vim-strip-trailing-whitespace'
    end
)

require("nvim-treesitter.configs").setup {
  ensure_installed = "all",
  ignore_install = { "haskell" }, -- keeps failing to install
  highlight = {
    enable = true,
    language_tree = true
  },
  indent = {
    enable = true
  },
  refactor = {
    highlight_definitions = {
      enable = true
    }
  },
  autotag = {
    enable = true
  },
  context_commentstring = {
    enable = true
  },
  textobjects = {
    select = {
      enable = true,
      keymaps = {
        ["af"] = "@function.outer",
        ["if"] = "@function.inner",
        ["ac"] = "@class.outer",
        ["ic"] = "@class.inner"
      }
    }
  }
}

local actions = require('telescope.actions')
require("telescope").setup {
  defaults = {
    file_ignore_patterns = { 'bower_components', 'node_modules', '.gems', 'gen/', 'dist/', 'packs/', 'packs-test/', 'build/', 'external/' },
    mappings = {
      i = {
        ["<C-j>"] = actions.move_selection_next,
        ["<C-k>"] = actions.move_selection_previous
      }
    }
  }
}

vim.cmd [[colorscheme dracula_pro]]
-- vim.cmd [[colorscheme onedark]]
