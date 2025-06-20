return {
  -- EditorConfig is built into Neovim 0.9+, no plugin needed
  
  -- Highlights and removes trailing whitespace
  {
    'echasnovski/mini.trailspace',
    version = false,
    config = function()
      require('mini.trailspace').setup({
        -- Highlight only in normal buffers (ones with empty 'buftype')
        only_in_normal_buffers = true,
      })
      
      -- Auto-command to trim trailing whitespace on save
      vim.api.nvim_create_autocmd('BufWritePre', {
        pattern = '*',
        callback = function()
          -- Skip for specific filetypes
          local skip_filetypes = {
            'spectre_panel', 'diff', 'git', 'gitcommit',
            'unite', 'qf', 'help', 'markdown', 'fugitive'
          }
          if vim.tbl_contains(skip_filetypes, vim.bo.filetype) then
            return
          end
          require('mini.trailspace').trim()
        end,
      })
    end,
  },

  -- Automatically adjusts 'shiftwidth' and 'expandtab' heuristically
  {
    'NMAC427/guess-indent.nvim',
    config = function()
      require('guess-indent').setup({
        auto_cmd = true,  -- Set to true to automatically set options for file
        override_editorconfig = false,  -- Don't override settings from .editorconfig
        filetype_exclude = {  -- Filetypes to ignore
          'netrw',
          'tutor',
        },
        buftype_exclude = {  -- Buffer types to ignore
          'help',
          'nofile',
          'terminal',
          'prompt',
        },
      })
    end,
  },
}
