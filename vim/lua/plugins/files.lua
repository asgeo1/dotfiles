return {
  -- File manager for vim/neovim powered by n³
  {
    'mcchrish/nnn.vim',
    keys = {
      {
        '<leader>nt',
        ':NnnPicker<CR>',
        desc = 'Open explorer (NNN)',
        silent = true,
      },
      {
        '<leader>nf',
        ':NnnPicker %:p<CR>',
        desc = 'Show current file in explorer (NNN)',
        silent = true,
      },
    },
    config = function()
      -- Disable default mappings before setup
      vim.g['nnn#set_default_mappings'] = 0
      
      -- Configure nnn.vim
      vim.g['nnn#command'] = 'TERM=xterm-kitty nnn'
      vim.g['nnn#layout'] = {
        window = {
          width = 0.9,
          height = 0.6,
          highlight = 'Debug',
        },
      }
      vim.g['nnn#action'] = {
        ['<c-t>'] = 'tab split',
        ['<c-s>'] = 'split',
        ['<c-v>'] = 'vsplit',
      }
    end,
  },
}
