-- zoom-stack/capture.lua - Window layout capture functionality

local M = {}
local utils = require('zoom-stack.utils')

-- Capture the current window layout
function M.capture_layout()
  local layout = {
    timestamp = os.time(),
    windows = {},
    current_win = vim.api.nvim_get_current_win(),
    tab = vim.api.nvim_get_current_tabpage(),
  }
  
  -- Get all visible windows
  local windows = utils.get_visible_windows()
  if #windows == 0 then
    return nil
  end
  
  -- Capture each window's information
  for _, winid in ipairs(windows) do
    local win_info = M.get_window_info(winid)
    if win_info then
      table.insert(layout.windows, win_info)
    end
  end
  
  -- Capture the window layout structure (for Phase 2)
  -- For now, just store that we need to implement this
  layout.layout_cmd = "only" -- Placeholder - will be replaced with actual layout commands
  
  return layout
end

-- Get comprehensive information about a window
function M.get_window_info(winid)
  if not vim.api.nvim_win_is_valid(winid) then
    return nil
  end
  
  local bufnr = vim.api.nvim_win_get_buf(winid)
  local cursor = vim.api.nvim_win_get_cursor(winid)
  local view = vim.fn.winsaveview()
  
  -- Get window position and dimensions
  local position = utils.get_window_position(winid)
  
  -- Get buffer info
  local buf_info = utils.get_buffer_info(bufnr)
  if not buf_info then
    return nil
  end
  
  local win_info = {
    winid = winid,
    bufnr = bufnr,
    buf_info = buf_info,
    cursor = cursor,
    view = view,
    position = position,
    options = M.get_window_options(winid),
  }
  
  return win_info
end

-- Get window-local options that should be preserved
function M.get_window_options(winid)
  local options = {}
  
  -- List of window-local options to preserve
  local option_names = {
    'wrap', 'number', 'relativenumber', 'signcolumn',
    'foldmethod', 'foldlevel', 'foldcolumn', 'foldenable',
    'scrolloff', 'sidescrolloff', 'cursorline', 'cursorcolumn',
    'colorcolumn', 'spell', 'list', 'conceallevel', 'concealcursor',
    'linebreak', 'breakindent', 'showbreak',
  }
  
  -- Safely get each option
  for _, opt in ipairs(option_names) do
    local ok, value = pcall(vim.api.nvim_win_get_option, winid, opt)
    if ok then
      options[opt] = value
    end
  end
  
  return options
end

-- Analyze window layout (placeholder for Phase 2)
function M.analyze_layout()
  -- TODO: Implement using vim.fn.winlayout()
  -- This will generate the commands needed to recreate the layout
  return {}
end

-- Generate layout commands (placeholder for Phase 2)
function M.generate_layout_commands(layout_tree)
  -- TODO: Convert layout tree to executable commands
  return {"only"}
end

return M