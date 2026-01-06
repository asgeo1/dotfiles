local M = {}

-- Helper function to remove the suffix
local function remove_base_suffix(base_file)
  -- Assuming the suffix is `_BASE_<number>.ext`
  return base_file:gsub('_BASE_%d+', '')
end

-- Detect the type of git operation in progress
local function detect_git_operation()
  local status = vim.fn.system('git status 2>/dev/null')
  if status:match('rebase in progress') or status:match('interactive rebase in progress') then
    return 'rebase'
  elseif status:match('cherry%-pick') then
    return 'cherry-pick'
  elseif status:match('revert') then
    return 'revert'
  elseif status:match('merge') or status:match('Unmerged paths') then
    return 'merge'
  end
  return 'unknown'
end

-- Get MINE/THEIRS labels based on git operation
-- During merge: LOCAL=MINE, REMOTE=THEIRS
-- During rebase: LOCAL=THEIRS, REMOTE=MINE (reversed!)
local function get_ownership_labels(operation)
  if operation == 'rebase' then
    return {
      local_label = 'THEIRS (base branch)',
      remote_label = 'MINE (your commits)',
      base_label = 'BASE (common ancestor)',
    }
  else
    -- merge, cherry-pick, revert all follow the same pattern
    return {
      local_label = 'MINE (your branch)',
      remote_label = 'THEIRS (incoming)',
      base_label = 'BASE (common ancestor)',
    }
  end
end

-- Set winbar for a window based on its buffer name
local function set_window_labels_by_buffer(labels)
  local wins = vim.api.nvim_tabpage_list_wins(0)
  for _, win in ipairs(wins) do
    local buf = vim.api.nvim_win_get_buf(win)
    local name = vim.api.nvim_buf_get_name(buf)
    local label
    if name:match('_LOCAL_') then
      label = 'LOCAL → ' .. labels.local_label
    elseif name:match('_REMOTE_') then
      label = 'REMOTE → ' .. labels.remote_label
    elseif name:match('_BASE_') then
      label = labels.base_label
    end
    if label then
      vim.wo[win].winbar = '%#DiffText# ' .. label .. ' %*'
    end
  end
end

-- Function to set up the diff views
function M.SetupDiffViewFromBuffers()
  -- Helper function to check buffer existence and report errors
  local function find_buffer_or_report(pattern, description)
    for _, buffer in ipairs(vim.api.nvim_list_bufs()) do
      if vim.api.nvim_buf_is_loaded(buffer) then
        local name = vim.api.nvim_buf_get_name(buffer)
        if string.match(name, pattern) then
          return name
        end
      end
    end
    print('Error: ' .. description .. ' file could not be found.')
    return nil
  end

  -- Find the base file using the `_BASE_` pattern
  local base_file = find_buffer_or_report('_BASE_', 'Base')
  if not base_file then
    return
  end

  -- Derive the result file by removing the `_BASE_` suffix
  -- local result_file = remove_base_suffix(base_file)

  -- Find other files based on their patterns
  local local_file = find_buffer_or_report('_LOCAL_', 'Local')
  local remote_file = find_buffer_or_report('_REMOTE_', 'Remote')

  -- Stop if any other files could not be identified
  if not local_file or not remote_file then
    return
  end

  -- Detect git operation and get appropriate labels
  local operation = detect_git_operation()
  local labels = get_ownership_labels(operation)

  -- First TabPage: Base vs Local
  vim.cmd('tabnew ' .. base_file)
  vim.cmd('vsplit ' .. local_file)
  vim.cmd 'windo setlocal nofoldenable'
  vim.cmd 'windo diffthis'
  set_window_labels_by_buffer(labels)

  -- Second TabPage: Remote vs Base
  vim.cmd('tabnew ' .. remote_file)
  vim.cmd('vsplit ' .. base_file)
  vim.cmd 'windo setlocal nofoldenable'
  vim.cmd 'windo diffthis'
  set_window_labels_by_buffer(labels)

  vim.cmd 'tabfirst'

  -- Print helpful message
  local op_display = operation == 'unknown' and 'conflict' or operation
  print(string.format(
    '[%s] LOCAL=%s | REMOTE=%s',
    op_display:upper(),
    labels.local_label,
    labels.remote_label
  ))
end

return M
