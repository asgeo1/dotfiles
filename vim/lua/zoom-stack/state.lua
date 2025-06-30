-- zoom-stack/state.lua - State management for zoom stack
-- Manages per-tabpage zoom stacks and state

local M = {}

-- Global state table
-- Structure:
-- {
--   [tabpage_handle] = {
--     layouts = { ... },      -- Stack of layout snapshots
--     is_zoomed = false,      -- Current zoom state
--     original_win = nil,     -- Original window before zooming
--     original_showtabline = nil, -- Original showtabline value
--   }
-- }
M.stacks = {}

-- Initialize state management
function M.setup()
  -- Ensure we have a stack for the current tab
  local current_tab = vim.api.nvim_get_current_tabpage()
  M.ensure_stack(current_tab)
end

-- Ensure a stack exists for the given tabpage
function M.ensure_stack(tabpage)
  if not M.stacks[tabpage] then
    M.stacks[tabpage] = {
      layouts = {},
      is_zoomed = false,
      original_win = nil,
      original_showtabline = nil,
    }
  end
  return M.stacks[tabpage]
end

-- Get the stack for a tabpage
function M.get_stack(tabpage)
  return M.ensure_stack(tabpage)
end

-- Push a layout onto the stack
function M.push_layout(tabpage, layout)
  local stack = M.ensure_stack(tabpage)
  table.insert(stack.layouts, layout)
  return #stack.layouts
end

-- Pop a layout from the stack
function M.pop_layout(tabpage)
  local stack = M.get_stack(tabpage)
  if #stack.layouts == 0 then
    return nil
  end
  return table.remove(stack.layouts)
end

-- Peek at the top layout without removing it
function M.peek_layout(tabpage)
  local stack = M.get_stack(tabpage)
  if #stack.layouts == 0 then
    return nil
  end
  return stack.layouts[#stack.layouts]
end

-- Get stack depth
function M.get_depth(tabpage)
  local stack = M.get_stack(tabpage)
  return #stack.layouts
end

-- Set zoom state
function M.set_zoomed(tabpage, zoomed)
  local stack = M.ensure_stack(tabpage)
  stack.is_zoomed = zoomed
end

-- Check if currently zoomed
function M.is_zoomed(tabpage)
  local stack = M.get_stack(tabpage)
  return stack.is_zoomed
end

-- Set original window
function M.set_original_window(tabpage, winid)
  local stack = M.ensure_stack(tabpage)
  stack.original_win = winid
end

-- Get original window
function M.get_original_window(tabpage)
  local stack = M.get_stack(tabpage)
  return stack.original_win
end

-- Clean up state for a tabpage
function M.cleanup_tab(tabpage)
  -- Restore showtabline if it was changed
  local stack = M.stacks[tabpage]
  if stack and stack.original_showtabline ~= nil then
    vim.o.showtabline = stack.original_showtabline
  end
  
  -- Remove the stack
  M.stacks[tabpage] = nil
end

-- Clear all layouts for a tabpage
function M.clear_layouts(tabpage)
  local stack = M.ensure_stack(tabpage)
  stack.layouts = {}
  stack.is_zoomed = false
  stack.original_win = nil
end

-- Get all stacks (for debugging)
function M.get_all_stacks()
  return M.stacks
end

-- Validate stack integrity
function M.validate_stack(tabpage)
  local stack = M.get_stack(tabpage)
  
  -- Remove invalid layouts (where buffers no longer exist)
  local valid_layouts = {}
  for _, layout in ipairs(stack.layouts) do
    local all_valid = true
    for _, win_info in ipairs(layout.windows) do
      if not vim.api.nvim_buf_is_valid(win_info.bufnr) then
        all_valid = false
        break
      end
    end
    if all_valid then
      table.insert(valid_layouts, layout)
    end
  end
  
  stack.layouts = valid_layouts
  
  -- Update zoom state if needed
  if #stack.layouts == 0 then
    stack.is_zoomed = false
  end
  
  return #valid_layouts
end

-- Debug function to print stack state
function M.debug_print(tabpage)
  local stack = M.get_stack(tabpage or vim.api.nvim_get_current_tabpage())
  print("ZoomStack Debug Info:")
  print(string.format("  Tab: %s", tabpage or "current"))
  print(string.format("  Stack depth: %d", #stack.layouts))
  print(string.format("  Is zoomed: %s", stack.is_zoomed))
  print(string.format("  Original window: %s", stack.original_win or "none"))
  
  for i, layout in ipairs(stack.layouts) do
    print(string.format("  Layout %d:", i))
    print(string.format("    Windows: %d", #layout.windows))
    print(string.format("    Current window: %s", layout.current_win or "none"))
  end
end

return M