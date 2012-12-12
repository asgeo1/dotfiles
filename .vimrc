"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Adam's VIM CONFIGURATION FILE
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Vundle
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set nocompatible
filetype off

set rtp+=~/.vim/bundle/vundle/
call vundle#rc()

" let Vundle manage Vundle
Bundle 'gmarik/vundle'

" Github bundles
Bundle 'tpope/vim-fugitive'
Bundle 'mileszs/ack.vim'
Bundle 'Lokaltog/vim-easymotion'
Bundle 'rbgrouleff/bclose.vim'
Bundle 'fabi1cazenave/suckless.vim'
Bundle 'majutsushi/tagbar'
Bundle 'kien/ctrlp.vim'
Bundle 'Lokaltog/vim-powerline'
Bundle 'tpope/vim-repeat'
Bundle 'tpope/vim-surround'
Bundle 'jmcantrell/vim-reporoot'
Bundle 'scrooloose/syntastic'
Bundle 'scrooloose/nerdcommenter'
Bundle 'scrooloose/nerdtree'
Bundle 'asgeo1/nerdtree_hacks'
Bundle 'mattn/webapi-vim'
Bundle 'mattn/gist-vim'

Bundle 'kana/vim-textobj-function'
Bundle 'kana/vim-textobj-user'
Bundle 'austintaylor/vim-indentobject'
Bundle 'nelstrom/vim-textobj-rubyblock'
Bundle 'bootleq/vim-textobj-rubysymbol'
Bundle 'kchmck/vim-coffee-script'
Bundle 'tpope/vim-rails'
Bundle 'pangloss/vim-javascript'
Bundle 'briancollins/vim-jst'
Bundle 'vim-ruby/vim-ruby'
Bundle 'altercation/vim-colors-solarized'

" Vim-scripts bundles
Bundle 'IndexedSearch'
Bundle 'scratch.vim'
Bundle 'argtextobj.vim'
Bundle 'ZoomWin'

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Performance issues of editing remote files - this function will turn off several features which lead to poor performance when
" editing remote files via mapped network shares in windows
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:NotEditingRemotely = 1

function! s:ToggleRemoteFile()
    if exists("g:NotEditingRemotely")
        " Disable the matchparen.vim plugin
        :NoMatchParen

        " Turn off detection of the type of file
        filetype off

        " Disable the netrwPlugin.vim
        au! Network
        au! FileExplorer

        " Remove tag scanning (t) and included file scanning (i)
        set complete=.,w,b,u

        " Remove these autocommands which were added by vimBallPlugin.vim
        au! BufEnter *.vba
        au! BufEnter *.vba.gz
        au! BufEnter *.vba.bz2
        au! BufEnter *.vba.zip

        " Remove these custom autogroups (cannot be redone)
        au! lastTabPageVisited
        au! setFoldText

        unlet g:NotEditingRemotely

        :echo 'Remote Edit mode turned on'
    else
        " Enable the matchparen.vim plugin
        :DoMatchParen

        " Turn on detection of files
        filetype on

        " Add back in tag scanning (t) and included file scanning (i)
        " . = current buffer
        " w = buffers from other windows
        " b = other loaded buffers in the buffer list
        " u = unloaded buffers in the buffer list
        " t = tag completion
        " i = scan current and included files (see 'include' option)
        " k = scan the files given with the 'dictionary' option
        set complete=.,w,b,u,t,i

        let g:NotEditingRemotely = 1

        :echo 'Remote Edit mode turned off'
    endif
endfunction

command! -nargs=0 ToggleRemoteFile call s:ToggleRemoteFile()
noremap <F6> :ToggleRemoteFile<CR>

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" General
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set clipboard=unnamed   " The unnamed register is the \" register, and the Windows Clipboard is the * register.
                        " Setting 'clipboard' option to 'unnamed' so you always yank to *. Then pasting to windows apps doesn't
                        " require prefixing "*
set nocompatible        " Set vim not compatible with vi
set history=50          " Keep 50 lines of command line history
set cf                  " Enable error files and error jumping
set shell=/bin/zsh
filetype on             " Detect the type of file
let mapleader = ","     " Slash (\) to cumbersome to type as the leader character

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Colors/Schemes
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
if &t_Co > 2 || has("gui_running")
    syntax on                   " Switch syntax highlighting on, when the terminal has colors
endif

if has("win32")
    set guifont=consolas:h10    " Set font
else
    set guifont=Monaco-Powerline:h12      " Set font
endif

set background=dark             " We are using a dark background

if !has("gui_running")
    set t_Co=256
endif

colorscheme solarized

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
    set backupdir=C:/Program\ Files/Vim/vimfiles/tmp/backup   " Where to put backup file
    set directory=C:/Program\ Files/Vim/vimfiles/tmp/swap     " Directory is the directory for temp file
    if has("persistent_undo")
        set undodir=C:/Program\ Files/Vim/vimfiles/tmp/undo   " Where to save undo history
    endif
else
    set backupdir=~/.vim/tmp/backup     " Where to put backup file
    set directory=~/.vim/tmp/swap       " Directory is the directory for temp file
    if has("persistent_undo")
        set undodir=~/.vim/tmp/undo     " Where to save undo history
    endif
endif
set makeef=error.err                    " When using make, where should it dump the file

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Saving Sessions and Views
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" This is pissing me off :-/
" set sessionoptions=help,blank,winpos,resize,winsize   " what is saved in a session
" set viewoptions=folds,options,cursor                  " what is saved in a view
" set viminfo='1000,f1,:100,/100,%,!                    " what is saved in .viminfo file

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Vim UI
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! GuiTabLabel()
    let label = ''
    let bufnrlist = tabpagebuflist(v:lnum)

    " Append the tab number
    let label .= tabpagenr().': '

    " Add '+' if one of the buffers in the tab page is modified
    for bufnr in bufnrlist
        if getbufvar(bufnr, "&modified")
            let label .= '* '
            break
        endif
    endfor

    " Append the buffer name
    let name = bufname(bufnrlist[tabpagewinnr(v:lnum) - 1])
        if name == ''
        " give a name to no-name documents
        if &buftype=='quickfix'
            let name = '[Quickfix List]'
        else
            let name = '[No Name]'
        endif
    else
        " get only the file name
        let name = fnamemodify(name,":t")
    endif

    let label .= name

    " Append the number of windows in the tab page
    let wincount = tabpagewinnr(v:lnum, '$')

    if wincount > 1
        let wincount = ' [' . wincount . ']'
    else
        let wincount = ''
    endif

    return label . wincount
endfunction

" set up tab tooltips with every buffer name
function! GuiTabToolTip()
    let tip = ''
    let bufnrlist = tabpagebuflist(v:lnum)

    for bufnr in bufnrlist
        " separate buffer entries
        if tip!=''
            let tip .= ' | '
        endif

        " Add name of buffer
        let name=bufname(bufnr)

        if name == ''
            " give a name to no name documents
            if getbufvar(bufnr,'&buftype')=='quickfix'
                let name = '[Quickfix List]'
            else
                let name = '[No Name]'
            endif
        else
            let name = fnamemodify(name,":p")
        endif

        let tip.=name

        " add modified/modifiable flags
        if getbufvar(bufnr, "&modified")
            let tip .= ' [+]'
        endif

        if getbufvar(bufnr, "&modifiable")==0
            let tip .= ' [-]'
        endif
    endfor

    return tip
endfunction


" =======================================================
" IMPLEMENT A MOST RECENTLY USED MAPPING FOR TAB PAGES
map gb :exe "tabn " . g:ltv<CR>

function! SetLastTabPageVisited()
    let g:ltv = tabpagenr()
endfunction

augroup lastTabPageVisited
    au!

    autocmd VimEnter * let g:ltv = 1
    autocmd TabLeave * call SetLastTabPageVisited()
augroup END
" =======================================================


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
if ! &term =~ 'xterm'
    set wmh=0                       " The minimal height of a window, when it's not the current window
    set wmw=0                       " The minimal width of a window, when it's not the current window
endif
if has("win32") && has("gui_running")
    au GUIEnter * :silent Fullscreen " Turn on full-screen mode
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

        " When editing a file, always jump to the last known cursor position.
        " Don't do it when the position is invalid or when inside an event handler
        " (happens when dropping a file on gvim).
        " autocmd BufReadPost *
        "   \ if line("'\"") > 0 && line("'\"") <= line("$") |
        "   \   exe "normal g`\"" |
        "   \ endif
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
set guitablabel=%{GuiTabLabel()}        " Set custom tab page titles
set guitabtooltip=%{GuiTabToolTip()}    " Set custom tab tool tips

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
autocmd GUIEnter * set visualbell t_vb=""
set laststatus=2                    " Always show the status line
if ! &term =~ 'xterm'
    winpos 5 5                          " Start Vim at this co-ordinates of the screen
endif
set showcmd                         " Show information on the command in status line such as number of lines highlighted
" Using vim-powerline to set the status line now
"set statusline=%<%f\ %h%m%r%{fugitive#statusline()}%=%-7.(%l,%v%)\ %{&ff},%Y
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
set tabstop=4       " Number of spaces that a <Tab> in the file counts for
set shiftwidth=4    " Set number of spaces to used for each step of (auto)indent. (Used for 'cindent', >>, <<, etc
set softtabstop=4   " Number of spaces that a <Tab> counts for while performing editing operations, like inserting a <Tab> or using <BS>.
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
autocmd Filetype php :set iskeyword=@,48-57,_,128-167,224-235,$

" Coffeescript, use two-space indentation
au BufNewFile,BufReadPost *.coffee setl shiftwidth=2 tabstop=2 softtabstop=2 expandtab

" Coffeescript, use indentation for folding
au BufNewFile,BufReadPost *.coffee setl foldmethod=indent nofoldenable

" Don't use the Special group for @variables - looks too garish in solarised
hi def link coffeeSpecialVar Identifier

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

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Tags
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
if has("win32")
    autocmd Filetype php :set tags=$VIM/vimfiles/tags/zf
else
    autocmd Filetype php :set tags=~/.vim/tags/zf
endif

" if you want your tags to include vars/objects do:
" coffeetags --vim-conf --include-vars
if executable('coffeetags')
  let g:tagbar_type_coffee = {
        \ 'ctagsbin' : 'coffeetags',
        \ 'ctagsargs' : '',
        \ 'kinds' : [
        \ 'f:functions',
        \ 'o:object',
        \ ],
        \ 'sro' : ".",
        \ 'kind2scope' : {
        \ 'f' : 'object',
        \ 'o' : 'object',
        \ }
        \ }
endif

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Ctrl-P Plugin
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:ctrlp_map = '<leader>p'
let g:ctrlp_root_markers = ['Gemfile']

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Dbext Plugin
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:dbext_default_profile_gastrading_at_GASTRADING_DEV = $GASTRADING_AT_GASTRADING_DEV
let g:dbext_default_profile_muntzadmin_at_TRADING_DEV    = $MUNTZADMIN_AT_TRADING_DEV
let g:dbext_default_profile_eroster_at_ACTENT_TST        = $EROSTER_AT_ACTENT_TST
let g:dbext_default_profile_claymore_at_ACTENT_TST       = $CLAYMORE_AT_ACTENT_TST
let g:dbext_default_profile_mineotadmin_at_ACTENT_TST    = $MINEOTADMIN_ACTENT_TST
let g:dbext_default_profile_msmrs_at_ACTENT_TST          = $MSMRS_AT_ACTENT_TST
let g:dbext_default_use_win32_filenames                  = 1

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Ack Plugin
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:ackprg="ack -H --nocolor --nogroup --column"
let g:ackhighlight=1

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" PHP Syntax Options
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let php_parent_error_close = 1      " Show ({ that aren't closed properlly
let php_parent_error_open = 1       " Show )} that aren't opened properlly
let php_asp_tags = 1                " Color <? and ?> tags

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" NERDTree Plugin
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
noremap <leader>nt <Esc>:NERDTree<CR>
au Filetype nerdtree setlocal nolist
let NERDTreeMinimalUI = 1
let NERDTreeDirArrows = 1
let NERDTreeUseExistingWindows = 1

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Reporoot Plugin
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
noremap <Leader>cr <Esc>:RepoRoot<CR>:pwd<CR>

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" gist-vim
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:gist_show_privates = 1

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Powerline
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:Powerline_symbols = 'fancy'

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Suckless
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
noremap <silent> <leader>wh :call WindowMove("h")<CR>
noremap <silent> <leader>wj :call WindowMove("j")<CR>
noremap <silent> <leader>wk :call WindowMove("k")<CR>
noremap <silent> <leader>wl :call WindowMove("l")<CR>
noremap <silent> <leader>wH :call WindowResize("h")<CR>
noremap <silent> <leader>wJ :call WindowResize("j")<CR>
noremap <silent> <leader>wK :call WindowResize("k")<CR>
noremap <silent> <leader>wL :call WindowResize("l")<CR>

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
let my_tab=4
" allow toggling between local and default mode
function! TabToggle()
  if &expandtab
    set shiftwidth=4
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
noremap <F7> :let @/=''<CR> :echo 'Highlights Cleared'<CR>

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

" Use auto commands because 'nmap <C-Tab> :bn<cr>' wasn't working
autocmd GUIEnter * :map <C-Tab> :bn<CR>
autocmd GUIEnter * :map <C-S-Tab> :bp<cr>

""""""""""""""""""""""""""
" New/Save/Close commands
""""""""""""""""""""""""""
" Remap exit command imap
inoremap <M-F4> <ESC>:confirm:quit<CR>
nnoremap <M-F4> :confirm:quit<CR>
" Map close buffer
inoremap <C-F4> <ESC>:if !&modified <CR> :bwipe!<cr> :endif<cr><cr>
nnoremap <C-F4> :if !&modified <CR> :bwipe!<cr> :endif<cr><cr>

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
" Toggle sections of the UI on/off
"""""""""""""""""""""
if has("win32")
    nnoremap <C-F1> :if &go=~#'m'<Bar>set go-=m<Bar>else<Bar>set go+=m<Bar>endif<CR>
    nnoremap <C-F2> :if &go=~#'T'<Bar>set go-=T<Bar>else<Bar>set go+=T<Bar>endif<CR>
    nnoremap <C-F3> :if &go=~#'r'<Bar>set go-=r<Bar>else<Bar>set go+=r<Bar>endif<CR>
    nnoremap <C-F4> :if &go=~#'e'<Bar>set go-=e<Bar>set showtabline=0<Bar>else<Bar>set go+=e<Bar>set showtabline=2<Bar>endif<CR>
else
    "menubar is not relevant to mac
    nnoremap <D-F2> :if &go=~#'T'<Bar>set go-=T<Bar>else<Bar>set go+=T<Bar>endif<CR>
    nnoremap <D-F3> :if &go=~#'r'<Bar>set go-=r<Bar>else<Bar>set go+=r<Bar>endif<CR>
    nnoremap <D-F4> :if &go=~#'e'<Bar>set go-=e<Bar>set showtabline=0<Bar>else<Bar>set go+=e<Bar>set showtabline=2<Bar>endif<CR>
endif

"""""""""""""""""""""
" Change to directory of current file, and then print the working
" directory
"""""""""""""""""""""
nnoremap <leader>cd :lcd %:p:h<CR>:pwd<CR>
