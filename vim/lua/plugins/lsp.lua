return {
  -- LSP
  'neovim/nvim-lspconfig',

  -- Completion
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

      -- Makes the completion color items appear in the correct color
      'luckasRanarison/tailwind-tools.nvim',

      -- LSP kind icons for completion items
      'onsails/lspkind-nvim',
    },

    opts = function()
      return {
        formatting = {
          format = require('lspkind').cmp_format {
            before = require('tailwind-tools.cmp').lspkind_format,
          },
        },
      }
    end,
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
