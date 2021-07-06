vim.g.loaded_netrwPlugin = false
vim.cmd [[packadd cfilter]]


-- NOTES:
--
-- Packer plugins are installed into ~/.local/share/nvim/site/pack/packer
-- Packer logfile is here: ~/.cache/nvim/packer.nvim.log
-- packer_compiled.lua is here: ~/.vim/plugin/packer_compiled.vim


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
     run = ":TSUpdate"
   }
   use "nvim-treesitter/playground"
   use "nvim-treesitter/nvim-treesitter-refactor"
   use "nvim-treesitter/nvim-treesitter-textobjects"
   use "JoosepAlviste/nvim-ts-context-commentstring"

   use {
     "navarasu/onedark.nvim",
     --"monsonjeremy/onedark.nvim",
     setup = require("onedark").setup {}
   }

   use {
     'asgeo1/dracula-pro-vim',
     as = 'dracula'
   }

   use {
     "kyazdani42/nvim-web-devicons",
     setup = require("nvim-web-devicons").setup {
       default = true
     }
   }

   use "tpope/vim-fugitive" -- git integration
   use "tpope/vim-repeat" -- mappings for repeating keystrokes
   use "tpope/vim-sleuth" -- indentation

   use "airblade/vim-gitgutter"

   use "nvim-lua/plenary.nvim"
   use "nvim-lua/popup.nvim"
   use "nvim-telescope/telescope.nvim"

   use "rhysd/git-messenger.vim"
   use "michaeljsmith/vim-indent-object"
   use "machakann/vim-sandwich"
   use "AndrewRadev/splitjoin.vim"
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

   use {
     "folke/which-key.nvim",
     config = function()
       require("which-key").setup {
         -- your configuration comes here
         -- or leave it empty to use the default settings
         -- refer to the configuration section below
       }
     end
   }

   -- Neat, but has performance issue
   -- use 'jeffkreeftmeijer/vim-numbertoggle'

   -- performance issues, disabled:
   -- use 'ray-x/lsp_signature.nvim'
 end
)

if IsModuleAvailable("nvim-treesitter.configs") then
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
end

if IsModuleAvailable("telescope.actions") then
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
end

vim.cmd [[colorscheme dracula_pro]]
-- vim.cmd [[colorscheme onedark]]
