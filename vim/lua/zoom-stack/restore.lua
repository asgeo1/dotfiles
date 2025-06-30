-- zoom-stack/restore.lua - Window layout restoration functionality

local M = {}
local utils = require('zoom-stack.utils')

-- Restore a window layout
function M.restore_layout(layout)
  if not layout or not layout.windows or #layout.windows == 0 then
    return false
  end
  
  -- For now, implement basic restoration
  -- In Phase 3, we'll implement full layout recreation
  
  -- Start with a single window
  vim.cmd('only')
  
  -- If we have multiple windows, we need to create splits
  -- For now, just create simple splits (will be enhanced later)
  if #layout.windows > 1 then
    -- Create a simple grid layout as placeholder
    local success = M.create_simple_layout(layout.windows)
    if not success then
      return false
    end
  end
  
  -- Restore window contents
  local windows = utils.get_visible_windows()
  for i, win_info in ipairs(layout.windows) do
    if windows[i] then
      M.restore_window_state(windows[i], win_info)
    end
  end
  
  -- Try to focus the original window
  if layout.current_win then
    -- Find window with the same buffer
    for _, win in ipairs(windows) do
      local bufnr = vim.api.nvim_win_get_buf(win)
      -- Find the original buffer in our layout
      for _, win_info in ipairs(layout.windows) do
        if win_info.bufnr == bufnr then
          pcall(vim.api.nvim_set_current_win, win)
          break
        end
      end
    end
  end
  
  return true
end

-- Create a simple layout (temporary implementation)
function M.create_simple_layout(window_infos)
  local count = #window_infos
  
  if count == 2 then
    -- Create a vertical split
    vim.cmd('vsplit')
  elseif count == 3 then
    -- Create 2 vertical splits
    vim.cmd('vsplit')
    vim.cmd('vsplit')
  elseif count == 4 then
    -- Create a 2x2 grid
    vim.cmd('vsplit')
    vim.cmd('split')
    vim.cmd('wincmd l')
    vim.cmd('split')
  else
    -- For more complex layouts, just create vertical splits
    for i = 2, count do
      vim.cmd('vsplit')
    end
  end
  
  return true
end

-- Restore the state of a single window
function M.restore_window_state(winid, win_info)
  if not vim.api.nvim_win_is_valid(winid) then
    return false
  end
  
  -- Validate the buffer
  local ok, err = utils.can_restore_window(win_info)
  if not ok then
    -- Use a safe buffer as fallback
    win_info.bufnr = utils.get_safe_buffer()
  end
  
  -- Set the buffer
  local set_buf_ok = pcall(vim.api.nvim_win_set_buf, winid, win_info.bufnr)
  if not set_buf_ok then
    -- Try with a safe buffer
    local safe_buf = utils.get_safe_buffer()
    vim.api.nvim_win_set_buf(winid, safe_buf)
    return false
  end
  
  -- Restore cursor position
  if win_info.cursor then
    pcall(vim.api.nvim_win_set_cursor, winid, win_info.cursor)
  end
  
  -- Restore window options
  if win_info.options then
    M.restore_window_options(winid, win_info.options)
  end
  
  -- Restore view (scroll position, etc.)
  if win_info.view and winid == vim.api.nvim_get_current_win() then
    pcall(function()
      vim.fn.winrestview(win_info.view)
    end)
  end
  
  return true
end

-- Restore window-local options
function M.restore_window_options(winid, options)
  for opt, value in pairs(options) do
    pcall(vim.api.nvim_win_set_option, winid, opt, value)
  end
end

-- Recreate windows from layout commands (placeholder for Phase 3)
function M.recreate_windows(layout_cmds)
  -- TODO: Execute layout commands to recreate window structure
  for _, cmd in ipairs(layout_cmds) do
    pcall(vim.cmd, cmd)
  end
end

-- Clean up any temporary windows
function M.cleanup_empty_windows()
  local windows = utils.get_visible_windows()
  for _, win in ipairs(windows) do
    local buf = vim.api.nvim_win_get_buf(win)
    -- Check if it's an empty scratch buffer
    if vim.bo[buf].buftype == 'nofile' and 
       vim.api.nvim_buf_get_name(buf) == '' and
       vim.api.nvim_buf_line_count(buf) == 1 and
       vim.api.nvim_buf_get_lines(buf, 0, 1, false)[1] == '' then
      -- Close this window if it's not the last one
      if #windows > 1 then
        vim.api.nvim_win_close(win, false)
      end
    end
  end
end

return M