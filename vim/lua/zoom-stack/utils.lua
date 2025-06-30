-- zoom-stack/utils.lua - Utility functions

local M = {}

-- Get all visible (non-floating) windows in current tabpage
function M.get_visible_windows()
  local windows = {}
  local current_tab = vim.api.nvim_get_current_tabpage()
  
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(current_tab)) do
    if not M.is_floating_win(win) then
      table.insert(windows, win)
    end
  end
  
  return windows
end

-- Check if a window is floating
function M.is_floating_win(winid)
  local config = vim.api.nvim_win_get_config(winid)
  return config.relative ~= ""
end

-- Check if buffer is special (should not be restored normally)
function M.is_special_buffer(bufnr)
  if not vim.api.nvim_buf_is_valid(bufnr) then
    return true
  end
  
  local buftype = vim.bo[bufnr].buftype
  local special_types = {'quickfix', 'loclist', 'prompt', 'nofile', 'acwrite'}
  
  return vim.tbl_contains(special_types, buftype)
end

-- Get buffer info for special handling
function M.get_buffer_info(bufnr)
  if not vim.api.nvim_buf_is_valid(bufnr) then
    return nil
  end
  
  local info = {
    bufnr = bufnr,
    name = vim.api.nvim_buf_get_name(bufnr),
    buftype = vim.bo[bufnr].buftype,
    filetype = vim.bo[bufnr].filetype,
    modified = vim.bo[bufnr].modified,
  }
  
  -- Special handling for different buffer types
  if info.buftype == 'terminal' then
    info.terminal_job_id = vim.b[bufnr].terminal_job_id
  elseif info.buftype == 'help' then
    -- Extract help tag from buffer name
    local help_tag = info.name:match("help:(.+)")
    if help_tag then
      info.help_tag = help_tag
    end
  end
  
  return info
end

-- Deep copy a table
function M.deep_copy(obj, seen)
  if type(obj) ~= 'table' then
    return obj
  end
  
  if seen and seen[obj] then
    return seen[obj]
  end
  
  local s = seen or {}
  local res = setmetatable({}, getmetatable(obj))
  s[obj] = res
  
  for k, v in pairs(obj) do
    res[M.deep_copy(k, s)] = M.deep_copy(v, s)
  end
  
  return res
end

-- Get window position info
function M.get_window_position(winid)
  local pos = vim.api.nvim_win_get_position(winid)
  local width = vim.api.nvim_win_get_width(winid)
  local height = vim.api.nvim_win_get_height(winid)
  
  return {
    row = pos[1],
    col = pos[2],
    width = width,
    height = height,
  }
end

-- Check if two windows are adjacent
function M.are_windows_adjacent(win1_pos, win2_pos)
  -- Check horizontal adjacency
  if win1_pos.row == win2_pos.row and win1_pos.height == win2_pos.height then
    if win1_pos.col + win1_pos.width == win2_pos.col or
       win2_pos.col + win2_pos.width == win1_pos.col then
      return true, 'horizontal'
    end
  end
  
  -- Check vertical adjacency
  if win1_pos.col == win2_pos.col and win1_pos.width == win2_pos.width then
    if win1_pos.row + win1_pos.height == win2_pos.row or
       win2_pos.row + win2_pos.height == win1_pos.row then
      return true, 'vertical'
    end
  end
  
  return false, nil
end

-- Get a safe buffer to use (for restoration fallback)
function M.get_safe_buffer()
  -- Try to find a normal file buffer
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_valid(buf) and 
       vim.bo[buf].buftype == '' and
       not vim.bo[buf].modified then
      return buf
    end
  end
  
  -- Create a new empty buffer as fallback
  return vim.api.nvim_create_buf(true, false)
end

-- Format window info for display
function M.format_window_info(win_info)
  local buf_name = vim.api.nvim_buf_get_name(win_info.bufnr)
  if buf_name == '' then
    buf_name = '[No Name]'
  else
    buf_name = vim.fn.fnamemodify(buf_name, ':t')
  end
  
  return string.format("Win %d: %s (buf %d)", 
    win_info.winid or 0, 
    buf_name, 
    win_info.bufnr
  )
end

-- Validate window can be restored
function M.can_restore_window(win_info)
  -- Check if buffer is still valid
  if not vim.api.nvim_buf_is_valid(win_info.bufnr) then
    return false, "buffer no longer valid"
  end
  
  -- Check if buffer is loaded
  if not vim.api.nvim_buf_is_loaded(win_info.bufnr) then
    -- Try to load it
    local ok = pcall(vim.fn.bufload, win_info.bufnr)
    if not ok then
      return false, "buffer cannot be loaded"
    end
  end
  
  return true, nil
end

-- Get current tab layout summary (for debugging)
function M.get_layout_summary()
  local windows = M.get_visible_windows()
  local summary = {
    window_count = #windows,
    windows = {}
  }
  
  for _, win in ipairs(windows) do
    local bufnr = vim.api.nvim_win_get_buf(win)
    local buf_name = vim.api.nvim_buf_get_name(bufnr)
    table.insert(summary.windows, {
      winid = win,
      bufnr = bufnr,
      name = buf_name ~= '' and vim.fn.fnamemodify(buf_name, ':t') or '[No Name]',
      position = M.get_window_position(win),
    })
  end
  
  return summary
end

return M