return {
  -- EditorConfig plugin for Vim
  'editorconfig/editorconfig-vim',

  -- Causes all trailing whitespace characters to be highlighted
  {
    'ntpeters/vim-better-whitespace',
    config = function()
      vim.g.strip_whitespace_on_save = 1
      vim.g.better_whitespace_filetypes_blacklist = {
        'spectre_panel',
        'diff',
        'git',
        'gitcommit',
        'unite',
        'qf',
        'help',
        'markdown',
        'fugitive',
      }
      vim.g.strip_whitespace_confirm = 0
      vim.g.show_spaces_that_precede_tabs = 1
      vim.g.better_whitespace_operator = '_s'
      vim.g.strip_only_modified_lines = 1
    end,
  },

  -- Automatically adjusts 'shiftwidth' and 'expandtab' heuristically
  'tpope/vim-sleuth',
}
