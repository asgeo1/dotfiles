set background=dark
hi clear

if exists("syntax_on")
    syntax reset
endif

let g:colors_name = 'adams'

" Normal text
hi Normal       gui=NONE    guifg=#00CCFF       guibg=#000050
hi Visual       gui=NONE    guifg=#000066       guibg=#FFFF99

" the character under the cursor
hi Cursor                   guifg=#000066       guibg=#FFFF99   
hi lCursor                  guifg=bg            guibg=fg

" the column separating vertically split windows
hi VertSplit    gui=NONE    guifg=bg            guibg=#0A0A39

" error messages on the command line
hi ErrorMsg     gui=bold    guifg=red           guibg=white
hi Error        gui=bold    guifg=red           guibg=white

" directory names (and other special names in listings)
hi Directory                guifg=#00FF00       guibg=#000000

" diff mode: Added line |diff.txt|
hi DiffAdd      gui=none    guifg=#000220       guibg=#FFFCDF

" diff mode: Changed line |diff.txt|
hi DiffChange   gui=none    guifg=#1E0020       guibg=#E1FFDF

" diff mode: Deleted line |diff.txt|
hi DiffDelete   gui=none    guifg=#29292F       guibg=#000320

" diff mode: Changed text within a changed line |diff.txt|
hi DiffText     gui=bold    guifg=#00200D       guibg=#FFDFF2

" line used for closed folds
hi Folded                   guifg=#B0E3EB       guibg=bg

" 'foldcolumn' -- Turned off anyway
hi FoldColumn               guifg=#FFFF90       guibg=bg
hi SignColumn               guifg=#FFFF90       guibg=bg

"'incsearch' highlighting; also used for the text replaced with
"   ":s///c"
hi IncSearch    gui=bold    guifg=black         guibg=#D8FF00

" line number for ":number" and ":#" commands, and when 'number'
hi LineNr                   guifg=#FF6600

"'showmode' message (e.g., "-- INSERT --")
hi ModeMsg                  guifg=#00FF00       guibg=#000000

" |more-prompt|
hi MoreMsg                  guifg=#00FF00       guibg=#000000

"'~' and '@' at the end of the window, characters from 'showbreak' and other characters that do not really exist in
" the text (e.g., ">" displayed when a double-wide character doesn't fit at the end of the line).
hi NonText      gui=bold    guifg=#999999

" |hit-enter| prompt and yes/no questions
hi Question     gui=bold    guifg=white

" Last search pattern highlighting (see 'hlsearch'). Also used for highlighting the current line in the quickfix
" window and similar items that need to stand out.
hi Search       gui=bold    guifg=black         guibg=#FF8A00

" Meta and special keys listed with ":map", also for text used to show unprintable characters in the text, 'listchars'.
" Generally: text that is displayed differently from what it really is. (^I characters in register for example)
hi SpecialKey               guifg=#AEAEAE

" status line of current window
hi StatusLine   gui=bold    guifg=#FFFF90       guibg=#0A0A39   

" status lines of not-current windows Note: if this is equal to "StatusLine" Vim will use "^^^" in the status line of the current window.
hi StatusLineNC gui=NONE    guifg=white         guibg=#0A0A39

"titles for output from ":set all", ":autocmd" etc.
hi Title        gui=bold    guifg=#00FF00   

"Visual mode selection when vim is "Not Owning the Selection". Only X11 Gui's |gui-x11| and |xterm-clipboard| supports this.
hi VisualNOS    gui=bold,underline

"warning messages
hi WarningMsg   gui=bold    guifg=Red

"   current match in 'wildmenu' completion
hi WildMenu                 guifg=Black         guibg=Yellow

hi PMenu        gui=bold    guibg=#CECECE       guifg=#444444

hi Comment                  guifg=#999999
hi String                   guifg=#FF6600
hi Boolean                  guifg=#00FF00
hi Number                   guifg=#FF6600
hi Float                    guifg=#FF6600

" $ . || &&
hi Operator                 guifg=#0066FF

"While, if, else
hi Statement    gui=NONE    guifg=#00FF00
hi Conditional  gui=NONE    guifg=#00FF00

"Foreach, for
hi Repeat       gui=NONE    guifg=#00FF00

"Switch, case
hi Label        gui=NONE    guifg=#00FF00 

"global static  contained
hi StorageClass gui=NONE    guifg=#00FF00

"var contained
hi Keyword      gui=NONE    guifg=#00FF00

"Brackets
hi Delimiter                guifg=#0066FF

"Variables 
hi Identifier               guifg=fg
" hi Identifier             guifg=#00CCFF

"PHP functions
hi Function                 guifg=#FCEB14
hi Include                  guifg=#FCEB14

"
hi PreProc                  guifg=#0066FF

" New, Function keywords
hi Define                   guifg=#00FF00

"Class, extends
hi Structure                guifg=#00FF00

" \n and JavaScript stuff
hi Special                  guifg=#00CCFF
hi SpecialChar              guifg=#00CCFF

" NULL
hi Type         gui=NONE    guifg=#00FF00

" <script> tags ?
hi Exception                guifg=#FF6600

hi Todo                     guifg=#000066       guibg=#FFFF99

hi Tag                      guifg=white
hi Typedef                  guifg=white
hi PreCondit                guifg=white
hi SpecialComment           guifg=white
hi Character                guifg=white
