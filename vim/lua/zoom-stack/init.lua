-- zoom-stack.nvim - Stack-based window zooming for Neovim
-- Main module providing the public API

local M = {}

-- Module dependencies
local state = require('zoom-stack.state')
local capture = require('zoom-stack.capture')
local restore = require('zoom-stack.restore')
local utils = require('zoom-stack.utils')

-- Default configuration
local defaults = {
  keymaps = {
    zoom = "<C-w>o",
    restore = "<C-w>r",
    toggle = false, -- Disable toggle by default
  },
  hide_tabline = true,
  integrate_with_sessions = true,
  preserved_options = {
    "wrap", "number", "relativenumber", "signcolumn",
    "foldmethod", "foldlevel", "scrolloff", "sidescrolloff",
    "cursorline", "cursorcolumn", "colorcolumn", "spell",
    "list", "conceallevel", "concealcursor",
  },
  on_zoom = function(win) end,
  on_restore = function(win) end,
}

-- Plugin configuration
M.config = {}

-- Setup function
function M.setup(opts)
  M.config = vim.tbl_deep_extend("force", defaults, opts or {})
  
  -- Setup state management
  state.setup()
  
  -- Create commands
  vim.api.nvim_create_user_command('ZoomStackZoom', function()
    M.zoom()
  end, { desc = 'Zoom current window' })
  
  vim.api.nvim_create_user_command('ZoomStackRestore', function()
    M.restore()
  end, { desc = 'Restore previous window layout' })
  
  vim.api.nvim_create_user_command('ZoomStackToggle', function()
    M.toggle()
  end, { desc = 'Toggle zoom state' })
  
  -- Setup keymaps if not disabled
  if M.config.keymaps then
    if M.config.keymaps.zoom then
      vim.keymap.set('n', M.config.keymaps.zoom, M.zoom, { desc = 'Zoom window' })
    end
    if M.config.keymaps.restore then
      vim.keymap.set('n', M.config.keymaps.restore, M.restore, { desc = 'Restore window layout' })
    end
    if M.config.keymaps.toggle then
      vim.keymap.set('n', M.config.keymaps.toggle, M.toggle, { desc = 'Toggle zoom' })
    end
  end
  
  -- Setup autocmds for cleanup
  local augroup = vim.api.nvim_create_augroup('ZoomStack', { clear = true })
  
  -- Clean up state when tab is closed
  vim.api.nvim_create_autocmd('TabClosed', {
    group = augroup,
    callback = function(args)
      state.cleanup_tab(tonumber(args.match))
    end,
  })
end

-- Zoom the current window
function M.zoom()
  local current_tab = vim.api.nvim_get_current_tabpage()
  local current_win = vim.api.nvim_get_current_win()
  
  -- Check if we're already in a special state
  local windows = utils.get_visible_windows()
  if #windows == 1 and not state.is_zoomed(current_tab) then
    vim.notify("Already zoomed (only one window)", vim.log.levels.INFO)
    return
  end
  
  -- Capture current layout before zooming
  local layout_snapshot = capture.capture_layout()
  if not layout_snapshot then
    vim.notify("Failed to capture window layout", vim.log.levels.ERROR)
    return
  end
  
  -- Push current layout to stack
  state.push_layout(current_tab, layout_snapshot)
  
  -- Get the buffer from current window
  local bufnr = vim.api.nvim_win_get_buf(current_win)
  
  -- Save showtabline setting if this is first zoom
  local stack = state.get_stack(current_tab)
  if #stack.layouts == 1 and M.config.hide_tabline then
    stack.original_showtabline = vim.o.showtabline
    vim.o.showtabline = 0
  end
  
  -- Perform the zoom - close all windows except current
  vim.cmd('only')
  
  -- Ensure we're showing the right buffer
  if vim.api.nvim_buf_is_valid(bufnr) then
    vim.api.nvim_win_set_buf(0, bufnr)
  end
  
  -- Mark as zoomed
  state.set_zoomed(current_tab, true)
  
  -- Call user callback
  if M.config.on_zoom then
    M.config.on_zoom(vim.api.nvim_get_current_win())
  end
  
  vim.notify(string.format("Zoomed (stack depth: %d)", #stack.layouts), vim.log.levels.INFO)
end

-- Restore the previous window layout
function M.restore()
  local current_tab = vim.api.nvim_get_current_tabpage()
  local stack = state.get_stack(current_tab)
  
  -- Check if we have anything to restore
  if #stack.layouts == 0 then
    vim.notify("No window layout to restore", vim.log.levels.INFO)
    return
  end
  
  -- Pop layout from stack
  local layout = state.pop_layout(current_tab)
  if not layout then
    vim.notify("Failed to retrieve layout from stack", vim.log.levels.ERROR)
    return
  end
  
  -- Restore the layout
  local success = restore.restore_layout(layout)
  if not success then
    vim.notify("Failed to restore window layout", vim.log.levels.ERROR)
    -- Push it back on the stack so user can try again
    state.push_layout(current_tab, layout)
    return
  end
  
  -- Update zoom state
  if #stack.layouts == 0 then
    state.set_zoomed(current_tab, false)
    
    -- Restore showtabline if this was the last zoom
    if stack.original_showtabline ~= nil and M.config.hide_tabline then
      vim.o.showtabline = stack.original_showtabline
      stack.original_showtabline = nil
    end
  end
  
  -- Call user callback
  if M.config.on_restore then
    M.config.on_restore(vim.api.nvim_get_current_win())
  end
  
  vim.notify(string.format("Restored (stack depth: %d)", #stack.layouts), vim.log.levels.INFO)
end

-- Toggle zoom state
function M.toggle()
  local current_tab = vim.api.nvim_get_current_tabpage()
  
  if state.is_zoomed(current_tab) then
    -- Check if we actually have multiple layouts in the stack
    local stack = state.get_stack(current_tab)
    if #stack.layouts > 0 then
      M.restore()
    else
      -- We're in a weird state - single window but marked as zoomed
      state.set_zoomed(current_tab, false)
      vim.notify("Reset zoom state", vim.log.levels.INFO)
    end
  else
    M.zoom()
  end
end

-- Get current stack depth
function M.get_stack_depth()
  local current_tab = vim.api.nvim_get_current_tabpage()
  local stack = state.get_stack(current_tab)
  return #stack.layouts
end

-- Check if currently zoomed
function M.is_zoomed()
  local current_tab = vim.api.nvim_get_current_tabpage()
  return state.is_zoomed(current_tab)
end

return M