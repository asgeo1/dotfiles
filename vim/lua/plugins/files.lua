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
      require('nnn').setup {
        -- Disable default mappings
        set_default_mappings = false,

        -- specify `TERM` to ensure colors are used
        command = 'TERM=xterm-kitty nnn',

        layout = {
          window = {
            width = 0.9,
            height = 0.6,
            highlight = 'Debug',
          },
        },

        action = {
          ['<c-t>'] = 'tab split',
          ['<c-s>'] = 'split',
          ['<c-v>'] = 'vsplit',
        },
      }
    end,
  },
}
