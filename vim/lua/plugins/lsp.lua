return {
  -- LSP
  'neovim/nvim-lspconfig',
  {
    'hrsh7th/nvim-cmp',
    dependencies = {
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-nvim-lua',
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-path',
      'hrsh7th/cmp-calc',
      'hrsh7th/cmp-emoji',
      'ray-x/cmp-treesitter',
    },
  },

  -- LSP
  {
    'jose-elias-alvarez/nvim-lsp-ts-utils',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'neovim/nvim-lspconfig',
    },
  },

  -- LSP diagnostics displayed as virtual text
  {
    -- 'ErichDonGubler/lsp_lines.nvim', # github mirror, not updated as frequently
    'https://git.sr.ht/~whynothugo/lsp_lines.nvim',
    config = function()
      require('lsp_lines').setup()

      -- Disable virtual_text since it's redundant due to lsp_lines.
      vim.diagnostic.config {
        virtual_text = false,
      }
    end,
  },

  -- General purpose language server, useful for hooking up prettier/eslint
  {
    'jose-elias-alvarez/null-ls.nvim',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'neovim/nvim-lspconfig',
    },
  },

  -- GitHub Copilot uses OpenAI Codex to suggest code and entire functions
  -- in real-time right from your editor
  'github/copilot.vim',

  -- performance issues, disabled:
  --
  -- Show function signature when you type
  -- 'ray-x/lsp_signature.nvim',
}
