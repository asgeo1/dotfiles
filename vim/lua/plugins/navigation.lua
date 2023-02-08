return {
  -- general-purpose motion plugin for Neovim, with the ultimate goal of
  -- establishing a new standard interface for moving around in the visible
  -- area in Vim-like modal editors
  {
    'ggandor/leap.nvim',
    event = 'VeryLazy',
    -- This is just anoying IMO
    --
    -- f/F/t/T motions on steroids, building on the Leap interface
    -- dependencies = {
    --   { 'ggandor/flit.nvim', opts = { labeled_modes = 'nv' } },
    -- },
    config = function(_, opts)
      local leap = require 'leap'
      for k, v in pairs(opts) do
        leap.opts[k] = v
      end
      leap.add_default_mappings(true)

      vim.keymap.del({ 'x', 'o' }, 'x')
      vim.keymap.del({ 'x', 'o' }, 'X')

      -- To set alternative keys for "exclusive" selection:
      -- vim.keymap.set({'x', 'o'}, <some-other-key>, '<Plug>(leap-forward-till)')
      -- vim.keymap.set({'x', 'o'}, <some-other-key>, '<Plug>(leap-backward-till)')
    end,
  },

  -- automatically highlighting other uses of the word under the cursor using
  -- either LSP, Tree-sitter, or regex matching
  {
    'RRethy/vim-illuminate',
    event = 'BufReadPost',
    opts = { delay = 200 },
    config = function(_, opts)
      require('illuminate').configure(opts)
      vim.api.nvim_create_autocmd('FileType', {
        callback = function()
          local buffer = vim.api.nvim_get_current_buf()
          pcall(vim.keymap.del, 'n', ']]', { buffer = buffer })
          pcall(vim.keymap.del, 'n', '[[', { buffer = buffer })
        end,
      })
    end,
    -- stylua: ignore
    keys = {
      {
        ']]',
        function()
          require('illuminate').goto_next_reference(false)
        end,
        desc = 'Next Reference',
      },
      {
        '[[',
        function()
          require('illuminate').goto_prev_reference(false)
        end,
        desc = 'Prev Reference',
      },
    },
  },
}
