local M = {}

-- Helper function to remove the suffix
local function remove_base_suffix(base_file)
  -- Assuming the suffix is `_BASE_<number>.ext`
  return base_file:gsub('_BASE_%d+', '')
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
  local result_file = remove_base_suffix(base_file)

  -- Find other files based on their patterns
  local local_file = find_buffer_or_report('_LOCAL_', 'Local')
  local remote_file = find_buffer_or_report('_REMOTE_', 'Remote')

  -- Stop if any other files could not be identified
  if not local_file or not remote_file then
    return
  end

  -- First TabPage: Local vs Base
  vim.cmd('tab split' .. base_file)
  vim.cmd('vsplit ' .. local_file)
  vim.cmd 'windo diffthis'

  -- Second TabPage: Base vs Remote
  vim.cmd('tab split' .. remote_file)
  vim.cmd('vsplit ' .. base_file)
  vim.cmd 'windo diffthis'
end

return M
