"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Adam's VIM CONFIGURATION FILE
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Language Packs
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" - vim-sensible is automatically enabled by polygot, turn off as prefer using
"   my settings which seem faster
let g:polyglot_disabled = ['sensible']
let g:yats_host_keyword = 0

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Vundle
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set nocompatible
filetype off

if has("win32")
  set shell=cmd
  set shellcmdflag=/c
else
  set shell=/usr/local/bin/fish
endif

call plug#begin('~/.vim/plugged')

" UI
Plug 'asgeo1/dracula-pro-vim', { 'as': 'dracula' }
Plug 'mcchrish/nnn.vim'
Plug 'troydm/zoomwintab.vim', { 'on': ['ZoomWinTabIn', 'ZoomWinTabOut', 'ZoomWinTabToggle'] }
Plug 'itchyny/lightline.vim'
Plug 'rhysd/git-messenger.vim'
Plug 'rbong/vim-flog' "(git browser)

" Utilities
Plug 'dyng/ctrlsf.vim'
Plug 'henrik/vim-indexed-search'
Plug 'rbgrouleff/bclose.vim', { 'on': 'Bclose' }
Plug 'scrooloose/nerdcommenter'
Plug 'airblade/vim-rooter'

" LSP & autocomplete
" dependencies
Plug 'jose-elias-alvarez/nvim-lsp-ts-utils'
Plug 'mattn/efm-langserver'
" lspconfig
Plug 'neovim/nvim-lspconfig'
Plug 'hrsh7th/nvim-compe'
Plug 'nvim-lua/lsp-status.nvim'

" Tree-sitter - highlighting & indentation 
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
Plug 'nvim-treesitter/playground'

" Telescope - fuzzy finder and navigation
" dependencies
Plug 'nvim-lua/popup.nvim'
Plug 'nvim-lua/plenary.nvim'
" telescope
Plug 'nvim-telescope/telescope.nvim'
Plug 'nvim-telescope/telescope-symbols.nvim'

" Seldom used plugins
Plug 'ludovicchabant/vim-gutentags'
Plug 'easymotion/vim-easymotion'
" Plug 'machakann/vim-sandwich' " Disabled for now, as the `s` mapping is
" slowing down opening files into splits via NERDTree
Plug 'tpope/vim-fugitive'
Plug 'terryma/vim-multiple-cursors'

" Rarely used plugins
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-dispatch'
Plug 'tpope/vim-surround'
Plug 'janko-m/vim-test'
Plug 'jeetsukumaran/vim-indentwise'
Plug 'mbbill/undotree'

" Documentation
Plug 'asgeo1/vim-doc'

""Too slow for windows, seems fine on osx
if !has("win32")
  Plug 'airblade/vim-gitgutter'
  Plug 'editorconfig/editorconfig-vim'
endif

" Languages
Plug 'AndrewRadev/vim-eco', { 'for': 'eco' }
Plug 'tpope/vim-rails', { 'for': ['ruby', 'erb', 'yml'] }  " NOTE: this quite slow on vim startup time, but OK if just for ruby and erb
Plug 'octol/vim-cpp-enhanced-highlight', { 'for': ['cpp', 'c'] }
Plug 'sheerun/vim-polyglot'
Plug 'milch/vim-fastlane'
Plug 'stephpy/vim-yaml'

" Vim-scripts bundles
Plug 'vim-scripts/scratch.vim', { 'on':  'Scratch' }

call plug#end()

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" General
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"NOTE: I have disabled the unnamed register, because it breaks blockwise copy & paste
"
"set clipboard=unnamed  \" The unnamed register is the \" register, and the Windows Clipboard is the * register.
                        " Setting 'clipboard' option to 'unnamed' so you always yank to *. Then pasting to windows apps doesn't
                        " require prefixing "*

set nocompatible        " Set vim not compatible with vi
set history=50          " Keep 50 lines of command line history
set cf                  " Enable error files and error jumping
filetype on             " Detect the type of file
let mapleader = ","     " Slash (\) to cumbersome to type as the leader character

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Colors/Schemes
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
if &t_Co > 2 || has("gui_running")
    syntax on                   " Switch syntax highlighting on, when the terminal has colors
    set regexpengine=0          " Use newer (faster) regexp engine, for faster syntax highlighting
endif

if has("win32")
    set guifont=consolas:h10.5    " Set font
else
    set guifont=Monaco\ for\ Powerline:h12      " Set font
endif

set background=dark             " We are using a dark background

if !has("gui_running")
    if has('termguicolors')
        set t_8f=[38;2;%lu;%lu;%lum " Vim terminfo overrides. Needed in tmux for 256 color
        set t_8b=[48;2;%lu;%lu;%lum " Vim terminfo overrides. Needed in tmux for 256 color
        set termguicolors
    else
        set t_Co=256
    end
endif

let g:dracula_colorterm = 1 " Include background fill colors
silent! colorscheme dracula_pro

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Files/Backups
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
if has("vms")
    set nobackup                    " do not keep a backup file, use versions instead
else
    set backup                      " Make a backup file
endif

if has("persistent_undo")
    set undofile                        " Save undo to a file
endif

if has("win32")
    set backupdir=$HOME/vimfiles/tmp/backup   " Where to put backup file
    set directory=$HOME/vimfiles/tmp/swap     " Directory is the directory for temp file
    if has("persistent_undo")
        set undodir=$HOME/vimfiles/tmp/undo   " Where to save undo history
    endif
else
    set backupdir=~/.vim/tmp/backup     " Where to put backup file
    set directory=~/.vim/tmp/swap       " Directory is the directory for temp file
    if has("persistent_undo")
        set undodir=~/.vim/tmp/undo     " Where to save undo history
    endif
endif

set autoread                            " When a file has been detected to have been changed outside of Vim and it has not been changed inside of Vim, automatically read it again. When the file has been deleted this is not done.

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Vim UI
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set wildmenu                        " Turn on wildmenu (command line completion suggestions)
set wildignore+=.hg,.git,.svn                    " Version control
set wildignore+=*.aux,*.out,*.toc                " LaTeX intermediate files
set wildignore+=*.jpg,*.bmp,*.gif,*.png,*.jpeg   " binary images
set wildignore+=*.o,*.obj,*.exe,*.dll,*.manifest " compiled object files
set wildignore+=*.spl                            " compiled spelling word lists
set wildignore+=*.sw?                            " Vim swap files
set wildignore+=*.DS_Store                       " OSX bullshit
set wildignore+=.sass-cache                      " Sass
set wildignore+=*/tmp/*                          " Temporary files
set wildignore+=*/bin/*                          " Build artefacts
set wildignore+=*/gen/*                          " Build artefacts
set wildignore+=.vimtags                         " tags file
set wildignore+=*/log/*
set wildignore+=*/public/uploads/*
set wildignore+=*/bundle.js
set wildignore+=*.bundle
set wildignore+=*/www/*                          " Cordova www directory
set wildignore+=*/platforms/*                    " Cordova platforms directory
set wildignore+=*/plugins/*                      " Cordova plugins directory

set ruler                           " Show the cursor position all the time
set cmdheight=1                     " The command bar is 1 high
set signcolumn=yes                  " Always show the sign column
set number                          " Turn on line numbering
set lz                              " Do not redraw while running macros (much faster) (LazyRedraw)
set hidden                          " You can change buffers without saving
set backspace=indent,eol,start      " Allow backspacing over everything in insert mode
set whichwrap+=<,>,h,l              " backspace and cursor keys wrap to
if has("gui_running")
    set mouse=a                     " Use mouse everywhere
endif
set mousehide                       " Hide mouse cursor when not in use
set shortmess=at                    " Shortens messages to avoid 'press a key' prompt 
set report=0                        " Tell us when anything is changed via :...
set ttyfast                         " Indicates a fast terminal connection.  More characters will be sent to the screen for redrawing, instead of using insert/delete line commands.
set timeout
set timeoutlen=1000
set ttimeout
set ttimeoutlen=0                   " Fix slowness of changing from visual to normal mode in the terminal
set noshowmode                      " Don't show `-- INSERT --`, as lightline is already showing this

if ! &term =~ 'xterm'
    set wmh=0                       " The minimal height of a window, when it's not the current window
    set wmw=0                       " The minimal width of a window, when it's not the current window
endif

if has("win32") && has("gui_running")
    "au GUIEnter * :silent Fullscreen " Turn on full-screen mode
elseif has("gui_macvim")
    set fuoptions+=maxhorz          " Unsure the fullscreen view is maximised - useful for when changing monitor sizes after saving session
    set fuoptions+=maxvert
    au GUIEnter * set fu            " Turn on full-screen mode
endif

" Resize splits when the window is resized
au VimResized * exe "normal! \<c-w>="

if has("win32")
    augroup windowLocationOnStartup
    au!
        " maximize the screen when vim is started
        autocmd GUIEnter * :simalt ~x
    augroup END
endif

if has("win32")
    "backslashes are changed to forward slashes. (increases performance for UNC paths under windows)
    set shellslash
    source $vimruntime\mswin.vim    " Behave like a MS Windows Application (sets up some keybindings, menus, etc)

    " These settings are configured when calling "behave mswin" which is set
    " from mswin.vim. Reset to defaults:
    set selection=inclusive         " Reset to default
    set selectmode=                 " Get rid of crapy select mode
endif

" Characters to use for folding and seperators etc
set fillchars=vert:\ ,stl:\ ,stlnc:\
set define=function                     " Pattern to be used to find a macro definition.
set tabpagemax=50                       " Maximum number of tab pages to open using -p switch or :tab ball (Default is 10)
set showtabline=1                       " Only show the tab bar if there is more than one tab open
set switchbuf=usetab,useopen,split      " usetab  = jump to first tab that contains the specified buffer
                                        " useopen = Jump to the first open window that contains the specified buffer
                                        " split   = split window rather than using current window

" dynamically resize size of quickfix windows based on contents, min 3, max 25
au FileType qf call AdjustWindowHeight(3, 25)
function! AdjustWindowHeight(minheight, maxheight)
  exe max([min([line("$"), a:maxheight]), a:minheight]) . "wincmd _"
endfunction

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Searching
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set ignorecase                      " Easier to ignore case for searching     \c   and \C   toggle on and off
set smartcase                       " All lowercase string - case insensitive - all uppercase case sensitive
set gdefault                        " Global substitutions on by default
set hlsearch                        " Highlight searched for phrases
set incsearch                       " Highlight as you type you search phrase
set showmatch                       " Show matching brackets

" Don't move on *
nnoremap * *<c-o>

" Substitute
nnoremap <leader>s :%s//<left>

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Visual Cues
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set mat=5                           " How many tenths of a second to blink matching brackets for
set list                            " Show chars on end of line, whitespace, etc
set listchars=tab:\ \ ,trail:.,extends:>,precedes:< " Show end of line as $... (see help)
set scrolloff=10                    " Keep 10 lines (top/bottom) for scope. This has to do with scrolling the screen
set noerrorbells                    " Don't make noise on errors that have messages
" Don't blink or make noise on errors that have no message. Need to set this
" with autocmd, because variable t_vb is always reset after when gui starts
set noerrorbells visualbell t_vb=    "(console)
autocmd GUIEnter * set visualbell t_vb=""  "(gui)
set laststatus=2                    " Always show the status line
if ! &term =~ 'xterm'
    winpos 5 5                          " Start Vim at this co-ordinates of the screen
endif
set showcmd                         " Show information on the command in status line such as number of lines highlighted
set guioptions=cagt                 " What components and options of the GUI should be used (c=console dialogs for simple choices, a = autoselect, m = menu bar, g = inactive menu items are gray, t = tearoff menu items, T = include Toolbar, r = righthand scrollbar always present, R = righthand scrollbar always present when vert. split window, b = bottom scrollbar is present, e = show GUI tab line)
set titlestring=%t%(\ [%R%M]%)"     " Set title bar
set colorcolumn=80                  " Put the "color column" at col 80

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Text Formatting/Layout
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
filetype indent on  " Turn on special indenting rules for this filetype
filetype plugin on  " Load any special plugin files for this filetype
set autoindent      " Copy indent from current line when starting new line (<CR> o or O commands)
set smartindent     " Turn on smartindent
                    " Do c-style indenting
autocmd Filetype C,cpp,php,asp,aspx,java,js :set cindent
set tabstop=2       " Number of spaces that a <Tab> in the file counts for
set shiftwidth=2    " Set number of spaces to used for each step of (auto)indent. (Used for 'cindent', >>, <<, etc
set softtabstop=2   " Number of spaces that a <Tab> counts for while performing editing operations, like inserting a <Tab> or using <BS>.
set expandtab       " In Insert mode: Use the appropriate number of spaces to insert a <Tab>
set nowrap          " Do not wrap lines
set wrapmargin=0    " Turn off wrapping
set textwidth=0     " Turn off splitting long text line

" ensure utf-8 encoding
set fileencoding=utf8
set fileencodings=ucs-bom,utf8,prc
set encoding=utf-8

" Coffeescript, use indentation for folding
au BufNewFile,BufReadPost *.coffee setl foldmethod=indent nofoldenable

" Java/android should have wider columns
au Filetype java :set colorcolumn=100

" Don't use the Special group for @variables - looks too garish in solarised
hi def link coffeeSpecialVar Identifier
hi clear SignColumn

autocmd Filetype gitcommit :hi SpecialKey guifg=NONE guibg=NONE gui=NONE ctermfg=NONE ctermbg=NONE cterm=NONE
autocmd Filetype gitconfig :hi SpecialKey guifg=NONE guibg=NONE gui=NONE ctermfg=NONE ctermbg=NONE cterm=NONE
autocmd Filetype gitconfig :set noexpandtab

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Folding
"    Enable folding, but by default make it act like folding is off, because folding is annoying in anything but a few rare cases
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" default off for most file types
autocmd Filetype * :set nofoldenable
" set foldmethod=indent   " Make folding indent sensitive (for those file types which do not have folding algorithms built in)
set foldmethod=expr   " Use tree-sitter
set foldexpr=nvim_treesitter#foldexpr()
if has("win32")
    set foldlevelstart=1    " Start with this fold level (i.e. methods in PHP files are folded)
endif
set foldopen-=search    " Don't open folds when you search into them
set foldopen-=undo      " Don't open folds when you undo stuff
autocmd Filetype php :set foldlevelstart=1
autocmd Filetype js  :set foldlevelstart=2


" Set a nicer foldtext function
set foldtext=MyFoldText()
function! MyFoldText()
  let foldlinecount = foldclosedend(v:foldstart) - foldclosed(v:foldstart) + 1
  let prefix = "+--- "
  let fdnfo = prefix . "L" . string(v:foldlevel) . ", " . string(foldlinecount) . " lines:"
  return fdnfo
endfunction

augroup setFoldText
    " Remove all setFoldText autocommands
    au!

    " For some reason, Javascript.vim keeps setting the foldtext to something
    " else. Override this
    autocmd BufEnter * :set foldtext=MyFoldText()
augroup END

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" bclose - close a buffer without deleting the window
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:bclose_no_plugin_maps = 1
nnoremap <silent> <Leader>db :Bclose<CR>

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" CtrlSF Plugin
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:ctrlsf_ignore_dir = ['bower_components', 'node_modules', '.gems', 'gen', 'dist', 'packs', 'packs-test', 'build', 'external']
let g:ctrlsf_auto_close = 0
nmap <leader>fw <Plug>CtrlSFCwordPath
nmap <leader>fp <Plug>CtrlSFPrompt

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Lightline Plugin
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" shows the relative path to the file, rather than just the filename
let g:lightline = {
      \ 'colorscheme': 'dracula_pro',
      \ 'component_function': {
      \   'filename': 'LightLineFilename',
      \   'lspstatus': 'LspStatus'
      \ }
      \ }

let g:lightline.active = {
      \ 'right': [
      \   [ 'lineinfo' ],
      \   [ 'percent' ],
      \   [ 'fileformat', 'fileencoding', 'filetype', 'charvaluehex' ],
      \   [ 'lspstatus' ]
      \ ] }

let g:lightline.tabline = {
		    \ 'left': [ [ 'tabs' ] ],
		    \ 'right': [ ] } " Removes the 'close' button from the right of the tab line

function! LightLineFilename()
  return expand('%')
endfunction

function! LspStatus() abort
  if luaeval('#vim.lsp.buf_get_clients() > 0')
    return luaeval("require('lsp-status').status()")
  endif

  return ''
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" NNN
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Disable default mappings
let g:nnn#set_default_mappings = 0

" specify `TERM` to ensure colors are used
let g:nnn#command = 'TERM=xterm-kitty nnn'

let g:nnn#replace_netrw = 1

let g:nnn#layout = { 'window': { 'width': 0.9, 'height': 0.6, 'highlight': 'Debug' } }

let g:nnn#action = {
      \ '<c-t>': 'tab split',
      \ '<c-s>': 'split',
      \ '<c-v>': 'vsplit' }

nnoremap <silent> <leader>nt :NnnPicker<CR>
nnoremap <silent> <leader>nf :NnnPicker %:p<CR>

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Git Gutter Plugin
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:gitgutter_eager = 0
let g:gitgutter_realtime = 0
let g:gitgutter_git_executable = 'git'

" fix issue with background color of gitgutter signs
highlight GitGutterAdd          guifg=#009900 guibg=NONE ctermfg=2 ctermbg=0
highlight GitGutterChange       guifg=#bbbb00 guibg=NONE ctermfg=3 ctermbg=0
highlight GitGutterDelete       guifg=#ff2222 guibg=NONE ctermfg=1 ctermbg=0

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Flog
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" use `q` to quit, rather than `ZZ`
augroup myfloggroup
    autocmd FileType floggraph map <buffer> <silent> q <Plug>FlogQuit
    autocmd FileType floggraph map <buffer> <silent> ZZ <Plug>FlogQuit
augroup END

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Vim-rooter
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:rooter_patterns = ['.git', '.git/', '_darcs/', '.hg/', '.bzr/', '.svn/']
let g:rooter_silent_chdir = 1

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" ZoomWinTab
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" declare the mapping, so vim-plug will load on-demand
noremap <C-w>O <Esc>:ZoomWinTabToggle<CR>
let g:zoomwintab_hidetabbar = 0

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" vim-test
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" NOTE: disabled for now, as not really using and was clashing with fzf :Tags
"
" make test commands execute using dispatch.vim
" let test#strategy = "neoterm"
" nmap <silent> <leader>tn :TestNearest<CR>
" nmap <silent> <leader>tf :TestFile<CR>
" nmap <silent> <leader>ts :TestSuite<CR>
" nmap <silent> <leader>tl :TestLast<CR>
" nmap <silent> <leader>tv :TestVisit<CR>

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" nvim-treesitter
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
lua << EOF
require "nvim-treesitter.configs".setup {
  ensure_installed = { "bash", "css", "dockerfile", "fish", "html", "java", "javascript", "json", "jsonc", "lua", "php", "python", "ruby", "scss", "toml", "tsx", "typescript", "yaml" }, -- one of "all", "maintained" (parsers with maintainers), or a list of languages
  ignore_install = {}, -- List of parsers to ignore installing
  highlight = {
    enable = true, -- false will disable the whole extension
    disable = {},  -- list of language that will be disabled
  },
  indent = {
    enable = true
  },
  playground = {
    enable = true,
    disable = {},
    updatetime = 25, -- Debounced time for highlighting nodes in the playground from source code
    persist_queries = false, -- Whether the query persists across vim sessions
    keybindings = {
      toggle_query_editor = 'o',
      toggle_hl_groups = 'i',
      toggle_injected_languages = 't',
      toggle_anonymous_nodes = 'a',
      toggle_language_display = 'I',
      focus_language = 'f',
      unfocus_language = 'F',
      update = 'R',
      goto_node = '<cr>',
      show_help = '?',
    },
  }
}
EOF

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" nvim-lspconfig
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

"lua << EOF
"local format_options_prettier = {
"  semi = false,
"  singleQuote = false,
"  trailingComma = "all",
"  bracketSpacing = false,
"  configPrecedence = "prefer-file"
"}
"
"vim.g.format_options_typescript = format_options_prettier
"vim.g.format_options_javascript = format_options_prettier
"vim.g.format_options_typescriptreact = format_options_prettier
"vim.g.format_options_javascriptreact = format_options_prettier
"vim.g.format_options_json = format_options_prettier
"vim.g.format_options_css = format_options_prettier
"vim.g.format_options_scss = format_options_prettier
"vim.g.format_options_html = format_options_prettier
"vim.g.format_options_yaml = format_options_prettier
"vim.g.format_options_markdown = format_options_prettier
"
"_G.formatting = function()
"  if not vim.g[string.format("format_disabled_%s", vim.bo.filetype)] then
"    vim.lsp.buf.formatting(vim.g[string.format("format_options_%s", vim.bo.filetype)] or {})
"  end
"end
"EOF

lua << EOF
local nvim_lsp = require('lspconfig')
local lsp_status = require("lsp-status")

-- Use an on_attach function to only map the following keys 
-- after the language server attaches to the current buffer
local custom_attach = function(client, bufnr)
  lsp_status.register_progress()
  lsp_status.config(
    {
      status_symbol = "LSP ",
      indicator_errors = "E",
      indicator_warnings = "W",
      indicator_info = "I",
      indicator_hint = "H",
      indicator_ok = "ok"
    }
  )


  -- -- define prettier signs
  -- vim.fn.sign_define("LspDiagnosticsSignError", {text="", texthl="LspDiagnosticsError"})
  -- vim.fn.sign_define("LspDiagnosticsSignWarning", {text="", texthl="LspDiagnosticsWarning"})
  -- vim.fn.sign_define("LspDiagnosticsSignInformation", {text="", texthl="LspDiagnosticsInformation"})
  -- vim.fn.sign_define("LspDiagnosticsSignHint", {text="", texthl="LspDiagnosticsHint"})

  -- if client.resolved_capabilities.document_formatting then
  --   vim.cmd [[augroup Format]]
  --   vim.cmd [[autocmd! * <buffer>]]
  --   vim.cmd [[autocmd BufWritePost <buffer> lua formatting()]]
  --   vim.cmd [[augroup END]]
  -- end

  local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
  local function buf_set_option(...) vim.api.nvim_buf_set_option(bufnr, ...) end

  --Enable completion triggered by <c-x><c-o>
  buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')

  -- Mappings.
  local opts = { noremap=true, silent=true }

  -- See `:help vim.lsp.*` for documentation on any of the below functions
  buf_set_keymap('n', 'gD', '<Cmd>lua vim.lsp.buf.declaration()<CR>', opts)
  buf_set_keymap('n', 'gd', '<Cmd>lua vim.lsp.buf.definition()<CR>', opts)
  buf_set_keymap('n', 'K', '<Cmd>lua vim.lsp.buf.hover()<CR>', opts)
  buf_set_keymap('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
  buf_set_keymap('n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
  buf_set_keymap('n', '<space>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
  buf_set_keymap('n', '<space>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
  buf_set_keymap('n', '<space>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)
  buf_set_keymap('n', '<space>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
  buf_set_keymap('n', '<space>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
  buf_set_keymap('n', '<space>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
  buf_set_keymap('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
  buf_set_keymap('n', '<space>e', '<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>', opts)
  buf_set_keymap('n', '[d', '<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>', opts)
  buf_set_keymap('n', ']d', '<cmd>lua vim.lsp.diagnostic.goto_next()<CR>', opts)
  buf_set_keymap('n', '<space>q', '<cmd>lua vim.lsp.diagnostic.set_loclist()<CR>', opts)
  buf_set_keymap("n", "<leader>aF", "<cmd>lua vim.lsp.buf.formatting()<CR>", opts)
end

local custom_init = function(client)
  print('Language Server Protocol started!')

  if client.config.flags then
    client.config.flags.allow_incremental_sync = true
  end
end

-- TODO: perlls, angularls

nvim_lsp.bashls.setup {
  on_attach = custom_attach,
  capabilities = lsp_status.capabilities
}
nvim_lsp.dockerls.setup {
  on_attach = custom_attach,
  capabilities = lsp_status.capabilities
}
nvim_lsp.html.setup {
  on_attach = custom_attach,
  capabilities = lsp_status.capabilities
}
nvim_lsp.jsonls.setup {
  on_attach = custom_attach,
  capabilities = lsp_status.capabilities
}
nvim_lsp.phpactor.setup {
  on_attach = custom_attach,
  capabilities = lsp_status.capabilities
}
nvim_lsp.pyls.setup {
  on_attach = custom_attach,
  capabilities = lsp_status.capabilities
}
nvim_lsp.solargraph.setup {
  on_attach = custom_attach,
  capabilities = lsp_status.capabilities
}
nvim_lsp.sqlls.setup {
  on_attach = custom_attach,
  capabilities = lsp_status.capabilities
}
nvim_lsp.vimls.setup {
  on_attach = custom_attach,
  capabilities = lsp_status.capabilities
}
nvim_lsp.yamlls.setup {
  on_attach = custom_attach,
  capabilities = lsp_status.capabilities
}

nvim_lsp.tsserver.setup({
  on_attach = function(client)
    client.resolved_capabilities.document_formatting = false
    require "nvim-lsp-ts-utils".setup {}
    custom_attach(client)
  end,
  capabilities = lsp_status.capabilities
})

-- formatting
local prettier = {
  formatCommand = (
    function()
      if not vim.fn.empty(vim.fn.glob(vim.loop.cwd() .. '/.prettierrc')) then
        return "prettier --config ./.prettierrc"
      else
        return "prettier --config ~/.config/nvim/.prettierrc"
      end
    end
  )()
}

-- linting
local eslint = {
  lintCommand = "eslint_d -f unix --stdin --stdin-filename ${INPUT}",
  lintIgnoreExitCode = true,
  lintStdin = true,
  lintFormats = { "%f:%l:%c: %m" },
}

nvim_lsp.efm.setup {
  on_attach = custom_attach,
  init_options = {documentFormatting = true},
  root_dir = vim.loop.cwd,
  settings = {
        rootMarkers = {".git/"},
        languages = {
            typescript = {prettier, eslint},
            javascript = {prettier, eslint},
            typescriptreact = {prettier, eslint},
            javascriptreact = {prettier, eslint},
            json = {prettier},
            html = {prettier},
            scss = {prettier},
            css = {prettier},
            markdown = {prettier},
        }
    }
}


EOF

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" nvim-compe
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
lua << EOF
-- Compe setup
require'compe'.setup {
  enabled = true;
  autocomplete = true;
  debug = false;
  min_length = 1;
  preselect = 'enable';
  throttle_time = 80;
  source_timeout = 200;
  incomplete_delay = 400;
  max_abbr_width = 100;
  max_kind_width = 100;
  max_menu_width = 100;
  documentation = true;

  source = {
    path = true;
    nvim_lsp = true;
    nvim_lua = true;
    buffer = true;
  };
}

local t = function(str)
  return vim.api.nvim_replace_termcodes(str, true, true, true)
end

local check_back_space = function()
  local col = vim.fn.col('.') - 1
  if col == 0 or vim.fn.getline('.'):sub(col, col):match('%s') then
    return true
  else
    return false
  end
end

-- Use (s-)tab to:
--- move to prev/next item in completion menuone
--- jump to prev/next snippet's placeholder
_G.tab_complete = function()
  if vim.fn.pumvisible() == 1 then
    return t "<C-n>"
  elseif check_back_space() then
    return t "<Tab>"
  else
    return vim.fn['compe#complete']()
  end
end

_G.s_tab_complete = function()
  if vim.fn.pumvisible() == 1 then
    return t "<C-p>"
  else
    return t "<S-Tab>"
  end
end

vim.api.nvim_set_keymap("i", "<Tab>", "v:lua.tab_complete()", {expr = true})
vim.api.nvim_set_keymap("s", "<Tab>", "v:lua.tab_complete()", {expr = true})
vim.api.nvim_set_keymap("i", "<S-Tab>", "v:lua.s_tab_complete()", {expr = true})
vim.api.nvim_set_keymap("s", "<S-Tab>", "v:lua.s_tab_complete()", {expr = true})
EOF

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Telescope
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
lua << EOF
local actions = require('telescope.actions')
require "telescope".setup {
  defaults = {
    file_ignore_patterns = { 'bower_components', 'node_modules', '.gems', 'gen/', 'dist/', 'packs/', 'packs-test/', 'build/', 'external/' }
  }
}
EOF

nnoremap <leader>tf <cmd>lua require('telescope.builtin').find_files()<cr>
nnoremap <leader>tF <cmd>lua require('telescope.builtin').git_files()<cr>
nnoremap <leader>tg <cmd>lua require('telescope.builtin').live_grep()<cr>
nnoremap <leader>ts <cmd>lua require('telescope.builtin').grep_string()<cr>
nnoremap <leader>tS <cmd>lua require('telescope.builtin').symbols()<cr>
nnoremap <leader>tb <cmd>lua require('telescope.builtin').buffers()<cr>
nnoremap <leader>tB <cmd>lua require('telescope.builtin').builtin()<cr>
nnoremap <leader>tr <cmd>lua require('telescope.builtin').lsp_references()<cr>

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Multiple cursors
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:multi_cursor_use_default_mapping=0

" Default mapping
let g:multi_cursor_start_word_key      = '<C-n>'
let g:multi_cursor_select_all_word_key = '<C-a>'
let g:multi_cursor_start_key           = 'g<C-n>'
let g:multi_cursor_select_all_key      = 'g<C-a>'
let g:multi_cursor_next_key            = '<C-n>'
let g:multi_cursor_prev_key            = '<C-p>'
let g:multi_cursor_skip_key            = '<C-x>'
let g:multi_cursor_quit_key            = '<Esc>'

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" vim-json
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:vim_json_syntax_conceal = 0

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Python
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" skip checking if python is available at vim startup - improves vim startup
" time
let g:python_host_skip_check = 1
let g:python3_host_skip_check = 1

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"Ruby
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:ruby_path = system('echo $HOME/.rbenv/shims')

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"JSX & TSX (react)
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:jsx_ext_required = 0
let g:tsx_ext_required = 0

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" cpp syntax extended
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:cpp_class_scope_highlight = 1

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" PHP
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:php_var_selector_is_identifier = 1

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Custom Functions
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Replace leading spaces with tabs. Select range, then hit :SuperRetab($width) - by p0g and FallingCow
function! SuperRetab(width) range
    silent! exe a:firstline . ',' . a:lastline . 's/\v%(^ *)@<= {'. a:width .'}/\t/g'
endfunction

" Remove invalid EOL characters
" NOTE: ^M == Ctrl+Q Ctrl+M
function! s:ReplaceCarrotM()
    :silent! %s/$//gg
    :silent! %s///gg
    :silent! %s//\r/gg
endfunction

" Remove invalid EOL characters
" NOTE: This was handy for removing some strange characters that notepad++ sometimes adds into files
function! s:ReplaceCarrotM2()
    :silent! %s//\r/gg
endfunction

" Remove extra whitespace at the end of lines
function! s:RemoveExtraneousWhitespace()
    :silent! %s/[ \t]*$//gg
endfunction

" Toggle cursor line on/off
let g:IsCursorLine=1
let g:IsCursorCol=0
function! s:CursorLineColToggle()
    if exists("g:IsCursorCol") && exists("g:IsCursorLine")
        if g:IsCursorLine==0 && g:IsCursorCol==0
            :set cursorline
            let g:IsCursorLine=1
        elseif g:IsCursorLine==1 && g:IsCursorCol==0
            :set cursorcolumn
            let g:IsCursorCol=1
        elseif g:IsCursorLine==1 && g:IsCursorCol==1
            :set nocursorline
            :set nocursorcolumn
            let g:IsCursorLine=0
            let g:IsCursorCol=0
        endif
    endif
endfunction

" Clear highlights
noremap <leader>ch :let @/=''<CR> :echo 'Highlights Cleared'<CR>

" Replace ^M with proper new lines
command! -nargs=0 ReplaceCarrotM call s:ReplaceCarrotM()
noremap <silent> <F8> :ReplaceCarrotM<CR>:echo '^M Removed'<CR>

" Remove extraneous whitespace at the end of lines
command! -nargs=0 RemoveExtraneousWhitespace call s:RemoveExtraneousWhitespace()
noremap <silent> <F9> :RemoveExtraneousWhitespace<CR>:echo 'Extraneous whitespace removed'<CR>

" Toggle cursor line on/off
command! -nargs=0 CursorLineColToggle call s:CursorLineColToggle()
noremap <silent> <F12> :CursorLineColToggle<CR>:echo 'Toggled Column/Line'<CR>


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Custom Mappings  (don't put comments on same line - causes beeping :-/ )
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""""""""""""""""""
" Indenting
""""""""""""""""""""
" Remap indent forwards
nnoremap <Tab> >>
" Remap indent backwards
nnoremap <S-Tab> <<
" Re-highlight block after > command
vnoremap < <gv
vnoremap > >gv
vnoremap <S-Tab> <gv
vnoremap <Tab> >gv

"""""""""""""""""""""
" Insert blank lines
"""""""""""""""""""""
" Blank a line
nnoremap BL cc<ESC>
" Blank line above
nnoremap BU mzO<ESC>`z
" Blank line below
nnoremap BB mzo<ESC>`z

" Restore the C-Y command (scroll screen) - mswin.vim remaps this to redo
if has("win32")
    nmap <C-Y> <C-Y>
endif

"""""""""""""""""""""
" Moving lines up or down in a file
"""""""""""""""""""""
" enable eclipse style moving of lines
nmap <M-j> mz:m+<CR>`z==
nmap <M-k> mz:m-2<CR>`z==
imap <M-j> <Esc>:m+<CR>==gi
imap <M-k> <Esc>:m-2<CR>==gi
vmap <M-j> :m'>+<CR>gv=`<my`>mzgv`yo`z
vmap <M-k> :m'<-2<CR>gv=`>my`<mzgv`yo`z

"""""""""""""""""""""
" Change to directory of current file, and then print the working
" directory
"""""""""""""""""""""
nnoremap <leader>cD :lcd %:p:h<CR>:pwd<CR>

" Scroll one line at a time, but keep cursor position relative to the window
" rather than moving with the line
noremap <C-j> j<C-e>
noremap <C-k> k<C-y>
