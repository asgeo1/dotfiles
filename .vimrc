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
  set shell=/bin/zsh
endif

call plug#begin('~/.vim/plugged')

" UI
Plug 'morhetz/gruvbox'
Plug 'scrooloose/nerdtree', { 'on':  'NERDTreeToggle' }
Plug 'asgeo1/nerdtree_hacks', { 'on':  'NERDTreeToggle' }
Plug 'EvanDotPro/nerdtree-chmod', { 'on': 'NERDTreeToggle' }
Plug 'junegunn/goyo.vim', { 'on': 'Goyo' }
Plug 'troydm/zoomwintab.vim', { 'on': ['ZoomWinTabIn', 'ZoomWinTabOut', 'ZoomWinTabToggle'] }
Plug 'bling/vim-airline'
Plug 'ctrlpvim/ctrlp.vim', { 'on': 'CtrlP' }

" Utilities
Plug 'embear/vim-localvimrc'
Plug 'Chiel92/vim-autoformat', { 'on': 'Autoformat' }
Plug 'tpope/vim-fugitive'
Plug 'mhinz/vim-grepper'
Plug 'henrik/vim-indexed-search'
Plug 'Lokaltog/vim-easymotion'
Plug 'rbgrouleff/bclose.vim', { 'on': 'Bclose' }
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-surround'
Plug 'scrooloose/nerdcommenter'
Plug 'airblade/vim-rooter'
Plug 'janko-m/vim-test'
Plug 'scrooloose/syntastic'

"Too slow
if !has("win32")
  Plug 'airblade/vim-gitgutter'
  Plug 'editorconfig/editorconfig-vim'
endif

" Languages
Plug 'kchmck/vim-coffee-script', { 'for': 'coffee' }
Plug 'AndrewRadev/vim-eco', { 'for': 'eco' }
Plug 'vim-ruby/vim-ruby', { 'for': ['ruby', 'erb'] }
Plug 'tpope/vim-rails', { 'for': ['ruby', 'erb'] }  " NOTE: this is a little slow on vim startup time :-/
Plug 'pangloss/vim-javascript', { 'for': 'javascript' }
Plug 'briancollins/vim-jst', { 'for': ['jst', 'ejs'] }
Plug 'groenewege/vim-less', { 'for': 'less' }
Plug 'elzr/vim-json', { 'for': 'json' }
Plug 'digitaltoad/vim-jade', { 'for': 'jade' }
Plug 'wavded/vim-stylus', { 'for': 'styl' }

" Vim-scripts bundles
Plug 'scratch.vim', { 'on':  'Scratch' }

call plug#end()

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" General
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set clipboard=unnamedplus " The unnamed register is the \" register, and the Windows Clipboard is the * register.
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
        set t_8f=[38;2;%lu;%lu;%lum
        set t_8b=[48;2;%lu;%lu;%lum
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

set ruler                           " Show the cursor position all the time
set cmdheight=1                     " The command bar is 2 high
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
set showtabline=0                       " Don't show tab line by default
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
" Turn off splitting long text line
set textwidth=0

" ensure utf-8 encoding
set fileencoding=utf8
set fileencodings=ucs-bom,utf8,prc
set encoding=utf-8

" Set what is counted as a keyword in PHP
au Filetype php :set iskeyword=@,48-57,_,128-167,224-235,$

" Coffeescript, use indentation for folding
au BufNewFile,BufReadPost *.coffee setl foldmethod=indent nofoldenable

" Java/android should have wider columns
au Filetype java :set colorcolumn=100

" Don't use the Special group for @variables - looks too garish in solarised
hi def link coffeeSpecialVar Identifier
hi clear SignColumn

" PL/SQL goodies
au BufNewFile,BufReadPost *.bdy,*.spc,*.trg,*.fnc,*.prc,*.vw setl filetype=plsql listchars=tab:\ \ ,trail:\ ,extends:>,precedes:<
au BufNewFile,BufReadPost *.bdy,*.spc,*.trg,*.fnc,*.prc,*.vw hi SpecialKey guifg=NONE guibg=NONE gui=NONE ctermfg=NONE ctermbg=NONE cterm=NONE

" Execute file
noremap <leader>xp <Esc>ggVG:DBExecVisualSQL<cr>

autocmd Filetype gitcommit :hi SpecialKey guifg=NONE guibg=NONE gui=NONE ctermfg=NONE ctermbg=NONE cterm=NONE
autocmd Filetype gitconfig :hi SpecialKey guifg=NONE guibg=NONE gui=NONE ctermfg=NONE ctermbg=NONE cterm=NONE
autocmd Filetype gitconfig :set noexpandtab

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Folding
"    Enable folding, but by default make it act like folding is off, because folding is annoying in anything but a few rare cases
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" default off for most file types
autocmd Filetype * :set nofoldenable
" default on for php files
autocmd Filetype php :set foldenable
set foldmethod=indent   " Make folding indent sensitive (for those file types which do not have folding algorithms built in)
if has("win32")
    set foldlevelstart=1    " Start with this fold level (i.e. methods in PHP files are folded)
endif
set foldopen-=search    " Don't open folds when you search into them
set foldopen-=undo      " Don't open folds when you undo stuff
"turning off for now - changing from insert to normal mode is too slow on
"large files
"let php_folding = 1     " Fold PHP functions and classes and stuff between {} blocks
autocmd Filetype php :set foldlevel=1
autocmd Filetype php :set foldlevelstart=1
autocmd Filetype js  :set foldlevelstart=2

" Don't screw up folds when inserting text that might affect them, until
" leaving insert mode. Foldmethod is local to the window. Protect against
" screwing up folding when switching between windows.
if exists("php_folding") && (php_folding==1 || php_folding==2)
    autocmd Filetype php :autocmd InsertEnter * if !exists('w:last_fdm') | let w:last_fdm=&foldmethod | setlocal foldmethod=manual | endif
    autocmd Filetype php :autocmd InsertLeave,WinLeave * if exists('w:last_fdm') | let &l:foldmethod=w:last_fdm | unlet w:last_fdm | endif
endif


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
" Ctrl-P Plugin
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:ctrlp_map = '<leader>p'
let g:ctrlp_cmd = 'CtrlP'
let g:ctrlp_root_markers = ['Gemfile', 'Gruntfile.js', 'component.json', 'package.json', 'project.properties', 'AndroidManifest.xml']
let g:ctrlp_custom_ignore = {
  \ 'dir': '\v[\/](node_modules|bower_components|.gems|bin|gen|.vimtags)$'
  \ }
" needed so ctrl-p can be loaded as-needed
exe 'nn <silent>' g:ctrlp_map ':<c-u>'.g:ctrlp_cmd.'<cr>'

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Git Gutter Plugin
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:gitgutter_eager = 0
let g:gitgutter_realtime = 0

" fix issue with background color of gitgutter signs
highlight GitGutterAdd          guifg=#009900 guibg=NONE ctermfg=2 ctermbg=0
highlight GitGutterChange       guifg=#bbbb00 guibg=NONE ctermfg=3 ctermbg=0
highlight GitGutterDelete       guifg=#ff2222 guibg=NONE ctermfg=1 ctermbg=0

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Grepper
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
command! -nargs=* -complete=file GG Grepper! -open -tool git -query <args> -open -quickfix
command! -nargs=* -complete=file Ack Grepper! -open -tool ack -query <args>
nnoremap <leader>* :Grepper! -tool ack -cword<cr>

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" PHP Syntax Options
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let php_parent_error_close = 1      " Show ({ that aren't closed properlly
let php_parent_error_open = 1       " Show )} that aren't opened properlly
let php_asp_tags = 1                " Color <? and ?> tags
let loaded_syntastic_php_php_checker = 1

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" NERDTree Plugin
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
noremap <leader>nt <Esc>:NERDTree<CR>
au Filetype nerdtree setlocal nolist
let NERDTreeMinimalUI = 1
let NERDTreeDirArrows = 1
let NERDTreeUseExistingWindows = 1
let NERDTreeIgnore=['\gen$', '^bin$', '\~$', '^node_modules$', '^bower_components$']

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Vim-rooter
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:rooter_patterns = ['Gemfile', 'Gruntfile.js', 'component.json', 'package.json', 'project.properties', 'AndroidManifest.xml', '.git', '.git/', '_darcs/', '.hg/', '.bzr/', '.svn/']

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Airline
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:airline_powerline_fonts = 1

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" localvimrc
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"Make the decisions given when asked before sourcing local vimrc files
"persistent over multiple vim runs and instances. The decisions are written to
"the file defined by and |g:localvimrc_persistence_file|
let g:localvimrc_persistent = 2

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" vim-json
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:vim_json_syntax_conceal = 0

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" ZoomWinTab
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" declare the mapping, so vim-plug will load on-demand
noremap <C-w>o <Esc>:ZoomWinTabToggle<CR>

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" vim-test
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" make test commands execute using dispatch.vim
let test#strategy = "neoterm"
nmap <silent> <leader>tn :TestNearest<CR>
nmap <silent> <leader>tf :TestFile<CR>
nmap <silent> <leader>ts :TestSuite<CR>
nmap <silent> <leader>tl :TestLast<CR>
nmap <silent> <leader>tv :TestVisit<CR>

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

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" editor config
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:EditorConfig_core_mode = 'external_command' " install via `brew install editorconfig`

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
    :silent! %s/$//g
    :silent! %s///g
endfunction

" Remove invalid EOL characters
" NOTE: This was handy for removing some strange characters that notepad++ sometimes adds into files
function! s:ReplaceCarrotM2()
    :silent! %s//\r/g
endfunction

" Remove extra whitespace at the end of lines
function! s:RemoveExtraneousWhitespace()
    :silent! %s/[ \t]*$//g
endfunction

" Turn off backups (needed when using CodeKit)
function! DisableBackups()
    :set nobackup
    :set nowritebackup
    :set noswapfile
endfunction

" Format buffer as json
function! JsonFormatter()
    :set filetype=javascript
    :Autoformat
    :set filetype=json
endfunction

" Sort tab pages
func! s:SortTabs()
    for i in range(tabpagenr('$'),1,-1)
        :tabr
        for j in range(1,i-1)
            let t1 = fnamemodify(bufname(winbufnr(tabpagewinnr(0))),':t')
            :tabn
            let t2 = fnamemodify(bufname(winbufnr(tabpagewinnr(0))),':t')
            if t1 > t2
                tabp
                exec ":tabmove ".j
            endif
        endfor
    endfor
endfun

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

" virtual tabstops using spaces
let my_tab=2
" allow toggling between local and default mode
function! TabToggle()
  if &expandtab
    set shiftwidth=2
    set softtabstop=0
    set noexpandtab
  else
    execute "set shiftwidth=".g:my_tab
    execute "set softtabstop=".g:my_tab
    set expandtab
  endif
endfunction
nmap <leader>q mz:execute TabToggle()<CR>'z

" Clear highlights
noremap <leader>ch :let @/=''<CR> :echo 'Highlights Cleared'<CR>

" Replace ^M with proper new lines
command! -nargs=0 ReplaceCarrotM call s:ReplaceCarrotM()
noremap <silent> <F8> :ReplaceCarrotM<CR>:echo '^M Removed'<CR>

" Remove extraneous whitespace at the end of lines
command! -nargs=0 RemoveExtraneousWhitespace call s:RemoveExtraneousWhitespace()
noremap <silent> <F9> :RemoveExtraneousWhitespace<CR>:echo 'Extraneous whitespace removed'<CR>

" Sort tab pages
command! -nargs=0 SortTabs call s:SortTabs()
noremap <silent> <F10> :SortTabs<CR>:echo 'Tabs Sorted'<CR>

" Toggle cursor line on/off
command! -nargs=0 CursorLineColToggle call s:CursorLineColToggle()
noremap <silent> <F12> :CursorLineColToggle<CR>:echo 'Toggled Column/Line'<CR>

nmap <leader>db mz:execute DisableBackups()<CR>'z
nmap <leader>jf mz:execute JsonFormatter()<CR>'z


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
