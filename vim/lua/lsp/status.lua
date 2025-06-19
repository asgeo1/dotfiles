local M = {}
local servers = require 'lsp.servers'

M.show_status = function()
  -- Create floating window
  local buf = vim.api.nvim_create_buf(false, true)
  local width = vim.api.nvim_get_option 'columns'
  local height = vim.api.nvim_get_option 'lines'
  local win_height = math.ceil(height * 0.8 - 4)
  local win_width = math.ceil(width * 0.8)
  local row = math.ceil((height - win_height) / 2 - 1)
  local col = math.ceil((width - win_width) / 2)
  
  local opts = {
    style = 'minimal',
    relative = 'editor',
    width = win_width,
    height = win_height,
    row = row,
    col = col,
    border = 'rounded',
    title = 'LSP Server Status',
    title_pos = 'center',
  }

  local win = vim.api.nvim_open_win(buf, true, opts)
  
  -- Set buffer options
  vim.api.nvim_buf_set_option(buf, 'modifiable', true)
  vim.api.nvim_buf_set_option(buf, 'buftype', 'nofile')
  
  -- Add key mappings
  vim.api.nvim_buf_set_keymap(buf, 'n', 'q', ':q<CR>', { noremap = true, silent = true })
  vim.api.nvim_buf_set_keymap(buf, 'n', '<Esc>', ':q<CR>', { noremap = true, silent = true })
  
  -- Initial content
  local lines = {
    '┌─────────────────────────────────────────────────────────────────────┐',
    '│                          LSP Server Status                          │',
    '└─────────────────────────────────────────────────────────────────────┘',
    '',
    'Checking Node version...',
    '',
  }
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  
  -- Get Node version
  local home_dir = os.getenv 'HOME'
  local node_cmd = string.format(
    'export PATH="%s/.nodenv/bin:$PATH" && eval "$(nodenv init -)" && node --version',
    home_dir
  )
  
  vim.fn.jobstart({'bash', '-c', node_cmd}, {
    on_stdout = function(_, data)
      if data and data[1] and data[1] ~= '' then
        lines[5] = 'Node version (via nodenv): ' .. data[1]
        vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
      end
    end,
    on_exit = function()
      -- Add npm section header
      vim.list_extend(lines, {
        '',
        '══════════════════════════════════════════════════════════════════════',
        '  NPM-based Language Servers (managed by :InstallLspServers)',
        '══════════════════════════════════════════════════════════════════════',
        '',
      })
      vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
      
      -- Check npm packages
      local npm_count = 0
      local npm_total = vim.tbl_count(servers.npm_packages)
      local npm_results = {}
      
      for package, info in pairs(servers.npm_packages) do
        local npm_cmd = string.format(
          'export PATH="%s/.nodenv/bin:$PATH" && eval "$(nodenv init -)" && npm list -g --depth=0 2>/dev/null | grep "%s@"',
          home_dir,
          package
        )
        
        vim.fn.jobstart({'bash', '-c', npm_cmd}, {
          on_stdout = function(_, data)
            if data and data[1] and data[1] ~= '' then
              local version = data[1]:match('@(.+)$') or 'unknown'
              table.insert(npm_results, {
                name = info.name,
                status = '✓ Installed',
                version = version
              })
            end
          end,
          on_exit = function(_, exit_code)
            if exit_code ~= 0 then
              table.insert(npm_results, {
                name = info.name,
                status = '✗ Not installed',
                version = ''
              })
            end
            
            npm_count = npm_count + 1
            if npm_count == npm_total then
              -- Sort and add npm results
              table.sort(npm_results, function(a, b) return a.name < b.name end)
              for _, result in ipairs(npm_results) do
                table.insert(lines, string.format('  %-25s %-20s %s', result.name, result.status, result.version))
              end
              
              -- Add manual section
              vim.list_extend(lines, {
                '',
                '══════════════════════════════════════════════════════════════════════',
                '  Manually Installed Language Servers',
                '══════════════════════════════════════════════════════════════════════',
                '',
              })
              vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
              
              -- Check manual servers
              local manual_count = 0
              local manual_results = {}
              
              for _, server in ipairs(servers.manual_servers) do
                vim.fn.jobstart({'bash', '-c', 'command -v ' .. server.check_cmd:match('^%S+') .. ' && ' .. server.check_cmd}, {
                  on_stdout = function(_, data)
                    if data and data[1] then
                      for _, line in ipairs(data) do
                        if line ~= '' then
                          local version = line:match('(%d+%.%d+%.%d+)') or line:match('version (%S+)') or ''
                          if version ~= '' then
                            table.insert(manual_results, {
                              name = server.name,
                              status = '✓ Installed',
                              version = version
                            })
                            break
                          end
                        end
                      end
                    end
                  end,
                  on_exit = function(_, exit_code)
                    manual_count = manual_count + 1
                    
                    -- If not already added as installed, mark as not installed
                    local found = false
                    for _, r in ipairs(manual_results) do
                      if r.name == server.name then
                        found = true
                        break
                      end
                    end
                    if not found then
                      table.insert(manual_results, {
                        name = server.name,
                        status = '✗ Not installed',
                        version = ''
                      })
                    end
                    
                    if manual_count == #servers.manual_servers then
                      -- Sort and add manual results
                      table.sort(manual_results, function(a, b) return a.name < b.name end)
                      for _, result in ipairs(manual_results) do
                        table.insert(lines, string.format('  %-25s %-20s %s', result.name, result.status, result.version))
                      end
                      
                      -- Add footer
                      vim.list_extend(lines, {
                        '',
                        '══════════════════════════════════════════════════════════════════════',
                        '',
                        'Commands:',
                        '  :InstallLspServers  - Install/update all npm-based language servers',
                        '  :LspStatus          - Show this status window',
                        '  :LspInfo            - Show active LSP clients for current buffer',
                        '  q or <Esc>          - Close this window',
                        '',
                        'Note: Run :InstallLspServers to install missing npm-based servers',
                      })
                      
                      vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
                      vim.api.nvim_buf_set_option(buf, 'modifiable', false)
                    end
                  end
                })
              end
            end
          end
        })
      end
    end
  })
end

return M