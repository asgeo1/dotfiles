"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Adam's VIM CONFIGURATION FILE
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

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
Plug 'morhetz/gruvbox'
Plug 'scrooloose/nerdtree', { 'on':  'NERDTreeToggle' }
Plug 'asgeo1/nerdtree_hacks', { 'on':  'NERDTreeToggle' }
Plug 'EvanDotPro/nerdtree-chmod', { 'on': 'NERDTreeToggle' }
Plug 'Xuyuanp/nerdtree-git-plugin', { 'on': 'NERDTreeToggle' }
Plug 'troydm/zoomwintab.vim', { 'on': ['ZoomWinTabIn', 'ZoomWinTabOut', 'ZoomWinTabToggle'] }
Plug 'itchyny/lightline.vim'
Plug '/usr/local/opt/fzf'
Plug 'junegunn/fzf.vim'
" Disabled for now, because it causes problems with coc
" Plug 'roxma/vim-paste-easy'
Plug 'rhysd/git-messenger.vim'
Plug 'rbong/vim-flog' "(git browser)

" Utilities
Plug 'dyng/ctrlsf.vim'
Plug 'henrik/vim-indexed-search'
Plug 'rbgrouleff/bclose.vim', { 'on': 'Bclose' }
Plug 'scrooloose/nerdcommenter'
Plug 'airblade/vim-rooter'
Plug 'neoclide/coc.nvim', {'do': { -> coc#util#install()}}

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
Plug 'janko-m/vim-test'
Plug 'jeetsukumaran/vim-indentwise'
Plug 'mbbill/undotree'

" Documentation
Plug 'asgeo1/vim-doc'


"Too slow for windows, seems fine on osx
if !has("win32")
  Plug 'airblade/vim-gitgutter'
  Plug 'editorconfig/editorconfig-vim'
endif

" Languages
Plug 'AndrewRadev/vim-eco', { 'for': 'eco' }
Plug 'tpope/vim-rails', { 'for': ['ruby', 'erb', 'yml'] }  " NOTE: this quite slow on vim startup time, but OK if just for ruby and erb
Plug 'octol/vim-cpp-enhanced-highlight', { 'for': ['cpp', 'c'] }
Plug 'amadeus/vim-jsx', { 'for': ['javascript.jsx'] }
Plug 'peitalin/vim-jsx-typescript', { 'for': ['typescript.tsx'] }
Plug 'sheerun/vim-polyglot'
Plug 'reisub0/hot-reload.vim' "(flutter)
Plug 'milch/vim-fastlane'
Plug 'fatih/vim-go'
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

silent! colorscheme gruvbox

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
" Don't use vim syntax regexs - use perl/python syntax
nnoremap / /\v
vnoremap / /\v
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
set foldmethod=indent   " Make folding indent sensitive (for those file types which do not have folding algorithms built in)
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
" Language Packs
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:polyglot_disabled = ['jsx'] "disabling because using a fork above

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" bclose - close a buffer without deleting the window
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:bclose_no_plugin_maps = 1
nnoremap <silent> <Leader>db :Bclose<CR>

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" fzf plugin
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
nmap <leader>p :GFiles<CR>
nmap <leader>P :Files<CR>
nmap <leader>b :Buffers<CR>
nmap <leader>B :History<CR>
nmap <leader>t :BTags<CR>
nmap <leader>T :Tags<CR>

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" CtrlSF Plugin
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:ctrlsf_ignore_dir = ['bower_components', 'node_modules', '.gems', 'bin', 'gen', 'dist', 'packs', 'packs-test', 'build', 'external']
let g:ctrlsf_auto_close = 0
nmap <leader>fw <Plug>CtrlSFCwordPath
nmap <leader>fp <Plug>CtrlSFPrompt

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Lightline Plugin
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" shows the relative path to the file, rather than just the filename
let g:lightline = {
      \ 'colorscheme': 'gruvbox',
      \ 'component_function': {
      \   'filename': 'LightLineFilename',
      \   'cocstatus': 'coc#status'
      \ }
      \ }

let g:lightline.active = {
      \ 'right': [
      \   [ 'lineinfo' ],
      \   [ 'percent' ],
      \   [ 'fileformat', 'fileencoding', 'filetype', 'charvaluehex' ],
      \   [ 'cocstatus' ]
      \ ] }

let g:lightline.tabline = {
		    \ 'left': [ [ 'tabs' ] ],
		    \ 'right': [ ] } " Removes the 'close' button from the right of the tab line

function! LightLineFilename()
  return expand('%')
endfunction

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" NERDTree Plugin
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
noremap <leader>nt <Esc>:NERDTreeToggle<CR>
noremap <leader>nf <Esc>:NERDTreeFind<CR>
au Filetype nerdtree setlocal nolist
let NERDTreeMinimalUI = 1
let NERDTreeDirArrows = 1
let NERDTreeUseExistingWindows = 1
let NERDTreeIgnore=['^tags.lock$', '^tags.temp$', '^tags$', '^dist$', '^gen$', '^bin$', '\~$', '^node_modules$', '^bower_components$', '^tmp$', '^log$', '^packs$', '^packs-test$', '^www$', '^platforms$', '^plugins$', '^compile_commands.json$', '^build$', '^external$']
let NERDTreeWinSize=50

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
let g:rooter_patterns = ['composer.json', 'Gemfile', 'Gruntfile.js', 'bower.json', 'package.json', 'project.properties', 'AndroidManifest.xml', '.git', '.git/', '_darcs/', '.hg/', '.bzr/', '.svn/']
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
" Vim-Go
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" disable vim-go :GoDef short cut (gd), this is handled by LanguageClient [LC]
let g:go_def_mapping_enabled = 0

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Conquer of Completion (coc)
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"
" 'coc-tsserver' - Auto completion
" 'coc-tslint-plugin' - Language linting rules
" 'coc-prettier' - Formatting

let g:coc_global_extensions = [
      \ 'coc-tsserver',
      \ 'coc-tslint-plugin',
      \ 'coc-prettier',
      \ 'coc-angular',
      \ 'coc-ccls',
      \ 'coc-css',
      \ 'coc-html',
      \ 'coc-json'
      \ ]
" Other coc extensions that I'm not using:
" 'coc-yaml', 'coc-emoji'
" coc-git - not using for gutter, because too slow
" coc-eslint - uninstalled because it complains too much
" coc-solargraph (ruby) - too slow

" Some servers have issues with backup files, see #649
set nobackup
set nowritebackup

" You will have bad experience for diagnostic messages when it's default 4000.
set updatetime=300

" don't give |ins-completion-menu| messages.
set shortmess+=c

" Use tab for trigger completion with characters ahead and navigate.
" Use command ':verbose imap <tab>' to make sure tab is not mapped by other plugin.
inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Use <c-space> to trigger completion.
inoremap <silent><expr> <c-space> coc#refresh()

" " Close preview window when completion is done.
" autocmd! CompleteDone * if pumvisible() == 0 | pclose | endif

" Use <cr> to confirm completion, `<C-g>u` means break undo chain at current position.
" Coc only does snippet and additional edit on confirm.
inoremap <expr> <cr> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"

" NOTE: doesn't seem to be working well
"
" Use `[c` and `]c` to navigate diagnostics
" nmap <silent> [c <Plug>(coc-diagnostic-prev)
" nmap <silent> ]c <Plug>(coc-diagnostic-next)

" Remap keys for gotos
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" Use K to show documentation in preview window
nnoremap <silent> K :call <SID>show_documentation()<CR>

function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  else
    call CocAction('doHover')
  endif
endfunction

" Highlight symbol under cursor on CursorHold     DISABLED - TOO SLOW
" autocmd CursorHold * silent call CocActionAsync('highlight')

" Remap for rename current word
nmap <leader>rn <Plug>(coc-rename)

" Remap for format selected region (seems to clash a bit with CtrlSF)
xmap <leader>fs  <Plug>(coc-format-selected)
nmap <leader>fs  <Plug>(coc-format-selected)

augroup mygroup
  autocmd!
  " Setup formatexpr specified filetype(s).
  autocmd FileType typescript,json setl formatexpr=CocActionAsync('formatSelected')
  " Update signature help on jump placeholder
  autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
augroup end

" Remap for do codeAction of selected region, ex: `<leader>aap` for current paragraph
xmap <leader>a  <Plug>(coc-codeaction-selected)
nmap <leader>a  <Plug>(coc-codeaction-selected)

" Remap for do codeAction of current line
nmap <leader>ac  <Plug>(coc-codeaction)
" Fix autofix problem of current line
nmap <leader>qf  <Plug>(coc-fix-current)

" Format current buffer
nmap <leader>aF  <Plug>(coc-format)
command! -nargs=0 Prettier :CocCommand prettier.formatFile
nmap <leader>af  <Esc>:Prettier<CR>

autocmd User CocStatusChange,CocDiagnosticChange call lightline#update()

" Using CocList
" Show all diagnostics
nnoremap <silent> <space>d  :<C-u>CocList diagnostics<cr>
" Find symbol of current document
nnoremap <silent> <space>o  :<C-u>CocList outline<cr>
" Search workspace symbols
nnoremap <silent> <space>s  :<C-u>CocList -I symbols<cr>
" Do default action for next item.
nnoremap <silent> <space>j  :<C-u>CocNext<CR>
" Do default action for previous item.
nnoremap <silent> <space>k  :<C-u>CocPrev<CR>
" Resume latest coc list
nnoremap <silent> <space>p  :<C-u>CocListResume<CR>

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
