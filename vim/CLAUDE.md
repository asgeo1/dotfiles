# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Quick Start

This is a modern Neovim configuration written entirely in Lua. The configuration uses lazy.nvim for plugin management and provides comprehensive LSP support, AI integration, and developer productivity features.

### Prerequisites
- Neovim >= 0.8.0
- Node.js (managed via nodenv) for npm-based language servers
- Git for plugin installation

### Installation
1. Clone this repository to `~/.config/nvim/`
2. Open Neovim - plugins will auto-install on first run via lazy.nvim
3. Run `:InstallLspServers` to install Node.js-based language servers
4. Manually install other language servers as needed (see LSP Dependencies below)

## Important Commands

### LSP Commands
- `:InstallLspServers` - Install all npm-based language servers using nodenv
- `:LspStatus` - Show installation status of all LSP servers (installed/outdated/missing)
- `:LspInfo` - Show LSP status for current buffer
- `:LspLog` - View LSP log file
- `:LspRestart` - Restart LSP servers

### LSP Keybindings (when LSP is active)
- `gd` - Go to definition
- `gD` - Go to declaration
- `gr` - Find references
- `gi` - Go to implementation
- `K` - Hover documentation
- `<C-k>` - Signature help
- `<leader>wa` - Add workspace folder
- `<leader>wr` - Remove workspace folder
- `<leader>wl` - List workspace folders
- `<leader>D` - Type definition
- `<leader>rn` - Rename symbol
- `<leader>ca` - Code actions
- `<leader>e` - Show line diagnostics
- `[d` - Previous diagnostic
- `]d` - Next diagnostic
- `<leader>q` - Set diagnostics to location list
- `<leader>f` - Format document

### Plugin Management (Lazy.nvim)
- `:Lazy` - Open lazy.nvim UI
- `:Lazy update` - Update all plugins
- `:Lazy sync` - Sync plugins (install/update/clean)
- `:Lazy clean` - Remove unused plugins
- `:Lazy profile` - Profile plugin load times
- `:Lazy restore` - Restore plugins from lazy-lock.json

### Treesitter Commands
- `:TSUpdate` - Update Treesitter parsers
- `:TSInstall <language>` - Install specific parser
- `:TSBufEnable highlight` - Enable highlighting for buffer
- `:TSBufDisable highlight` - Disable highlighting for buffer
- `:InspectTree` - View Treesitter AST (replaces deprecated playground)
- `:EditQuery` - Edit Treesitter queries

### Custom Commands
- `:Format` - Format current buffer (uses LSP or prettier via none-ls)
- `:OR` - Organize imports (TypeScript/JavaScript)

### Key Navigation & Editing
- `<leader>` is mapped to `,`
- `<C-h/j/k/l>` - Navigate between windows
- `<leader>bd` - Delete buffer
- `<leader>be` - Edit buffer
- `<leader>b<tab>` - Switch to alternate buffer
- `Y` - Yank to end of line
- `n`/`N` - Centered search navigation
- `<leader>cd` - Change to current file's directory

### Telescope (Fuzzy Finder)
- `<leader>ff` - Find files
- `<leader>fg` - Live grep
- `<leader>fb` - Browse buffers
- `<leader>fh` - Help tags

### Git (Neogit & Gitsigns)
- `<leader>gs` - Git status (Neogit)
- `<leader>gc` - Git commit
- `<leader>gp` - Git push
- `<leader>gP` - Git pull
- `<leader>gb` - Git branch
- `<leader>gl` - Git log
- `<leader>gm` - Git blame current line
- `]h` / `[h` - Next/Previous git hunk
- `<leader>ghs` - Stage hunk
- `<leader>ghr` - Reset hunk
- `<leader>ghS` - Stage buffer
- `<leader>ghR` - Reset buffer
- `<leader>ghp` - Preview hunk
- `<leader>ghb` - Blame line (full)

### Autocomplete (nvim-cmp)
- `<C-p>`/`<C-n>` - Navigate completion items
- `<C-b>`/`<C-f>` - Scroll documentation
- `<C-Space>` - Trigger completion
- `<C-e>` - Close completion
- `<CR>` - Confirm selection
- `<Tab>`/`<S-Tab>` - Navigate snippet placeholders

## Architecture

### Directory Structure
```
.
├── init.lua                 # Entry point - loads all modules in order
├── lazy-lock.json          # Plugin version lock file (tracked in git)
└── lua/
    ├── config/             # Core Neovim configuration
    │   ├── autocmds.lua    # Auto commands (e.g., highlight on yank)
    │   ├── commands.lua    # Custom commands (InstallLspServers, Format, OR)
    │   ├── keymaps.lua     # Global key mappings
    │   ├── lazy.lua        # Plugin manager bootstrap and configuration
    │   └── options.lua     # Vim options (tabs, search, UI settings)
    ├── lsp/                # Language Server Protocol configuration
    │   ├── formatting.lua  # Document formatting setup
    │   ├── handlers.lua    # LSP handler customizations
    │   ├── init.lua        # LSP server configurations and on_attach
    │   ├── install.lua     # Helper to install npm-based servers
    │   └── rename.lua      # Enhanced rename functionality
    ├── plugins/            # Plugin specifications (lazy.nvim format)
    │   ├── autopairs.lua   # Auto-pairing brackets/quotes
    │   ├── cmp.lua         # Completion engine setup
    │   ├── colorscheme.lua # Theme configuration
    │   ├── dap.lua         # Debug Adapter Protocol
    │   ├── editing.lua     # Text editing enhancements
    │   ├── git.lua         # Git integration (fugitive, gitsigns)
    │   ├── lsp.lua         # LSP-related plugins
    │   ├── nnn.lua         # File manager integration
    │   ├── telescope.lua   # Fuzzy finder configuration
    │   ├── tmux.lua        # Tmux integration
    │   ├── treesitter.lua  # Syntax highlighting
    │   └── ui.lua          # UI enhancements
    └── util/               # Utility modules
        ├── init.lua        # Common utility functions
        └── lsp.lua         # LSP utility functions
```

### Plugin Management
- **Manager**: lazy.nvim (auto-installs on first run)
- **Lock file**: lazy-lock.json ensures reproducible plugin versions
- **Plugin specs**: Organized by category in lua/plugins/
- **Lazy loading**: Many plugins are lazy-loaded for performance

### LSP Configuration
- **Servers**: Configured in lua/lsp/init.lua
- **Auto-installed servers** (via npm/nodenv):
  - cssls, eslint, html, jsonls, ts_ls, vimls, yamlls, bashls,
  - dockerls, emmet_ls, graphql, prismals, stylelint_lsp, svelte,
  - tailwindcss, vuels, astro, pylsp
- **Manual installation required**:
  - gopls (Go), sumneko_lua (Lua), intelephense (PHP), solargraph (Ruby)
- **Completion**: nvim-cmp with LSP, buffer, path, and snippet sources
- **Formatting**: Uses none-ls (null-ls fork) with prettier
- **TypeScript**: Uses native ts_ls configuration (nvim-lsp-ts-utils removed, tsserver renamed to ts_ls)

### Notable Features
- **AI Integration**: GitHub Copilot and Avante.nvim
- **Git Integration**: Neogit, Gitsigns, Diffview, and Flog
- **Modern UI**: Telescope, Trouble, and lualine statusline
- **Smart Editing**: Treesitter, treesj, mini modules, and multicursors
- **File Management**: nnn.nvim integration
- **Testing**: vim-test with projectionist support

## LSP Dependencies

### Automatic Installation (via :InstallLspServers)
The command uses nodenv to install npm packages globally for the current Node version.

### Manual Installation Required

#### Go
```bash
go install golang.org/x/tools/gopls@latest
```

#### Lua
```bash
brew install lua-language-server
```

#### PHP
```bash
npm install -g intelephense
```

#### Ruby
```bash
gem install solargraph
```

## Troubleshooting

### Plugins not loading
1. Run `:Lazy sync` to ensure all plugins are installed
2. Check `:Lazy profile` for load errors
3. Ensure Neovim version >= 0.8.0

### LSP not working
1. Run `:LspInfo` to check server status
2. Run `:LspLog` to view error logs
3. Ensure language server is installed (see LSP Dependencies)
4. For npm-based servers, ensure nodenv is configured correctly

### Treesitter highlighting issues
1. Run `:TSUpdate` to update parsers
2. Run `:TSInstall <language>` for missing languages
3. Check `:checkhealth nvim-treesitter`

## Development Workflow

### Adding a new plugin
1. Create a new file in `lua/plugins/` or add to existing category file
2. Follow lazy.nvim spec format
3. Run `:Lazy sync` to install

### Adding a new LSP server
1. Add server configuration to `lua/lsp/init.lua`
2. If npm-based, add to the install list in `lua/lsp/install.lua`
3. Run `:InstallLspServers` or install manually

### Modifying keybindings
- Global keymaps: Edit `lua/config/keymaps.lua`
- LSP keymaps: Edit the `on_attach` function in `lua/lsp/init.lua`
- Plugin-specific: Check the plugin's configuration file in `lua/plugins/`