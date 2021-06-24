vim.cmd [[syntax enable]]
vim.cmd [[filetype plugin indent on]]

local opt =
    setmetatable(
    {},
    {
        __newindex = function(_, key, value)
            vim.o[key] = value
            vim.bo[key] = value
        end
    }
)

-- opt.dict = "~/dotfiles/lib/10k.txt"
opt.expandtab = true -- In Insert mode: Use the appropriate number of spaces to insert a <Tab>
opt.formatoptions = "crqnbj" -- original: jtcroql
opt.grepprg = "rg --vimgrep --no-heading --hidden"
opt.shiftwidth = 2 -- Set number of spaces to used for each step of (auto)indent. (Used for 'cindent', >>, <<, etc
opt.smartindent = true
opt.softtabstop = 2 -- Number of spaces that a <Tab> counts for while performing editing operations, like inserting a <Tab> or using <BS>.
opt.spellcapcheck = ""
opt.swapfile = false
opt.tabstop = 2 -- Number of spaces that a <Tab> in the file counts for
opt.textwidth = 0 -- turn off splitting long text line
opt.undofile = true
opt.undolevels = 10000

vim.o.clipboard = "unnamedplus" -- To ALWAYS use the clipboard for ALL operations (instead of interacting with the '+' and/or '*' registers explicitly): >
vim.o.completeopt = "menuone,noinsert,noselect" -- original: menu,preview
vim.o.confirm = true
vim.o.diffopt = "internal,filler,closeoff,foldcolumn:0,hiddenoff" -- orig: internal,filler,closeoff
vim.o.emoji = false
vim.o.foldclose = "all"
vim.o.foldopen = "all"
vim.o.hidden = true -- You can change buffers without saving
vim.o.history = 10000 -- Keep 10000 lines of command line history
vim.o.ignorecase = true -- Easier to ignore case for searching     \c   and \C   toggle on and off
vim.o.inccommand = "nosplit"
vim.o.infercase = true
vim.o.lazyredraw = true -- Do not redraw while running macros (much faster) (LazyRedraw)
vim.o.mouse = "a" -- Use mouse everywhere
vim.o.pumblend = 10 -- Enables pseudo-transparency for the popup-menu
vim.o.ruler = false -- Enables pseudo-transparency for the popup-menu
vim.o.scrolloff = 8 -- Keep 10 lines (top/bottom) for scope. This has to do with scrolling the screen
vim.o.showbreak = "" -- Don't show line break character "↳⋅"
vim.o.showcmd = true -- Show information on the command in status line such as number of lines highlighted
vim.o.showmode = false -- " Don't show `-- INSERT --`, as lightline is already showing this
vim.o.showtabline = 1 -- Only show the tab bar if there is more than one tab open
vim.o.sidescroll = 5 -- The minimal number of columns to scroll horizontally
vim.o.sidescrolloff = 15 -- The minimal number of screen columns to keep to the left and to the ight of the cursor if 'nowrap' is set
vim.o.smartcase = true -- All lowercase string - case insensitive - all uppercase case sensitive
vim.o.smarttab = true
vim.o.splitbelow = true
vim.o.splitright = true
vim.o.termguicolors = true
vim.o.timeoutlen = 500
vim.o.undodir = vim.fn.expand("~/.config/nvim/tmp/undo")
vim.o.updatetime = 0 -- If this many milliseconds nothing is typed the swap file will be written to disk
vim.o.viewoptions = "" -- folds,options,cursor,curdir
vim.o.virtualedit = ""
vim.o.whichwrap = "b,h,l" -- original: b,s,<,>,h,l
vim.o.wildmode = "longest,full" -- original: full
vim.o.wildoptions = "pum" -- original: pum,tagfile

vim.wo.foldenable = false
vim.wo.foldlevel = 2
vim.wo.foldmethod = "expr"
vim.wo.foldexpr = "nvim_treesitter#foldexpr()"
vim.wo.colorcolumn = '80' -- Put the "color column" at col 80
vim.wo.signcolumn = "yes:1" -- original: yes   Always show the sign column
vim.wo.conceallevel = 2 -- Concealed text is completely hidden unless it has a custom replacement character defined
vim.wo.concealcursor = "n"
vim.wo.breakindent = true -- Every wrapped line will continue visually indented (same amount of space as the beginning of that line), thus preserving horizontal blocks of text
vim.wo.linebreak = true -- If on, Vim will wrap long lines at a character in 'breakat' rather than at the last character that fits on the screen.
vim.wo.number = true
vim.wo.relativenumber = true
vim.wo.cursorline = true
vim.wo.winhighlight = "NormalNC:WinNormalNC"
vim.wo.list = true
vim.wo.listchars =
    table.concat(
    {
        "tab:│⋅",
        "trail:•",
        "extends:❯",
        "precedes:❮",
        "nbsp:_"
    },
    ","
)

vim.g.floating_window_border = {"╭", "─", "╮", "│", "╯", "─", "╰", "│"}
vim.g.floating_window_border_dark = {
    {"╭", "FloatBorderDark"},
    {"─", "FloatBorderDark"},
    {"╮", "FloatBorderDark"},
    {"│", "FloatBorderDark"},
    {"╯", "FloatBorderDark"},
    {"─", "FloatBorderDark"},
    {"╰", "FloatBorderDark"},
    {"│", "FloatBorderDark"}
}
vim.g.markdown_fenced_languages = {
    "vim",
    "python",
    "lua",
    "bash=sh",
    "javascript",
    "typescript",
    "yaml",
    "json",
    "gql=graphql",
    "graphql"
}
vim.g.no_man_maps = true
vim.g.vim_json_syntax_conceal = false
vim.g.vim_json_conceal = false
vim.g.mapleader = ","
