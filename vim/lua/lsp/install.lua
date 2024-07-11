local Job = require 'plenary.job'
local M = {}

local function create_floating_window()
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
  }

  local win = vim.api.nvim_open_win(buf, true, opts)

  -- Add a key mapping to close the window
  vim.api.nvim_buf_set_keymap(
    buf,
    'n',
    'q',
    ':q<CR>',
    { noremap = true, silent = true }
  )

  return buf, win
end

local function install_npm_package(
  buf,
  package,
  current_version,
  home_dir,
  callback
)
  Job
    :new({
      command = 'bash',
      args = {
        '-c',
        'export PATH="'
          .. home_dir
          .. '/.nodenv/bin:$PATH" && eval "$(nodenv init -)" && npm install -g '
          .. package,
      },
      env = vim.loop.os_environ(), -- Pass all environment variables
      on_stdout = function(_, line)
        vim.schedule(function()
          if line then
            vim.api.nvim_buf_set_lines(buf, -1, -1, false, { line })
          else
            vim.api.nvim_buf_set_lines(
              buf,
              -1,
              -1,
              false,
              { 'Received nil line in stdout' }
            )
          end
        end)
      end,
      on_stderr = function(_, line)
        vim.schedule(function()
          if line then
            vim.api.nvim_buf_set_lines(
              buf,
              -1,
              -1,
              false,
              { 'Error: ' .. line }
            )
          else
            vim.api.nvim_buf_set_lines(
              buf,
              -1,
              -1,
              false,
              { 'Received nil line in stderr' }
            )
          end
        end)
      end,
      on_exit = function(_, install_return_val)
        vim.schedule(function()
          if install_return_val ~= 0 then
            vim.api.nvim_buf_set_lines(buf, -1, -1, false, {
              'Failed to install '
                .. package
                .. ' for nodenv version: '
                .. current_version,
            })
          else
            vim.api.nvim_buf_set_lines(buf, -1, -1, false, {
              'Successfully installed '
                .. package
                .. ' for nodenv version: '
                .. current_version,
            })
          end
          if callback then
            callback()
          end
        end)
      end,
    })
    :start()
end

local function install_npm_packages_sequentially(
  buf,
  npm_packages,
  current_version,
  home_dir
)
  local function run_next(index)
    if index > #npm_packages then
      vim.schedule(function()
        vim.api.nvim_buf_set_lines(
          buf,
          -1,
          -1,
          false,
          { 'Finished installing all npm packages. Running nodenv rehash...' }
        )
        Job
          :new({
            command = 'bash',
            args = {
              '-c',
              'export PATH="'
                .. home_dir
                .. '/.nodenv/bin:$PATH" && eval "$(nodenv init -)" && nodenv rehash',
            },
            env = vim.loop.os_environ(),
            on_exit = function(_, rehash_return_val)
              vim.schedule(function()
                if rehash_return_val ~= 0 then
                  vim.api.nvim_buf_set_lines(
                    buf,
                    -1,
                    -1,
                    false,
                    { 'Failed to run nodenv rehash' }
                  )
                else
                  vim.api.nvim_buf_set_lines(
                    buf,
                    -1,
                    -1,
                    false,
                    { 'Successfully ran nodenv rehash' }
                  )
                end
                vim.api.nvim_buf_set_keymap(
                  buf,
                  'n',
                  'q',
                  ':q<CR>',
                  { noremap = true, silent = true }
                )
              end)
            end,
          })
          :start()
      end)
      return
    end

    local package = npm_packages[index]
    install_npm_package(buf, package, current_version, home_dir, function()
      run_next(index + 1)
    end)
  end

  run_next(1)
end

M.install_npm_packages = function()
  -- Create the floating window
  local buf, win = create_floating_window()

  -- List of npm packages to install globally
  local npm_packages = {
    'typescript-language-server',
    'vscode-langservers-extracted',
    'cssmodules-language-server',
    'css-variables-language-server',
    'vim-language-server',
    'sql-language-server',
    'bash-language-server',
    'dockerfile-language-server-nodejs',
    '@microsoft/compose-language-service',
    'pyright',
    'yaml-language-server',
    '@tailwindcss/language-server',

    -- Not actually a LSP, but still useful to have
    'neovim',
  }

  local home_dir = os.getenv 'HOME'
  local nodenv_path = home_dir .. '/.nodenv/bin/nodenv'

  if not home_dir or not nodenv_path then
    vim.api.nvim_buf_set_lines(
      buf,
      -1,
      -1,
      false,
      { 'Error: HOME or nodenv_path is nil' }
    )
    return
  end

  -- Get the current node version via nodenv
  Job
    :new({
      command = 'bash',
      args = {
        '-c',
        'export PATH="'
          .. home_dir
          .. '/.nodenv/bin:$PATH" && eval "$(nodenv init -)" && nodenv version',
      },
      env = vim.loop.os_environ(), -- Pass all environment variables
      on_stdout = function(_, line)
        vim.schedule(function()
          if line then
            vim.api.nvim_buf_set_lines(
              buf,
              -1,
              -1,
              false,
              { 'nodenv version output: ' .. line }
            )
          end
        end)
      end,
      on_stderr = function(_, line)
        vim.schedule(function()
          if line then
            vim.api.nvim_buf_set_lines(
              buf,
              -1,
              -1,
              false,
              { 'Error: ' .. line }
            )
          end
        end)
      end,
      on_exit = function(job, return_val)
        vim.schedule(function()
          if return_val ~= 0 then
            vim.api.nvim_buf_set_lines(
              buf,
              -1,
              -1,
              false,
              { 'Failed to retrieve current nodenv version' }
            )
            return
          end

          local result = job:result()
          if not result or #result == 0 then
            vim.api.nvim_buf_set_lines(
              buf,
              -1,
              -1,
              false,
              { 'Error: No current version returned' }
            )
            return
          end

          local version_info = result[1]
          local current_version = version_info:match '^%S+'

          if not current_version then
            vim.api.nvim_buf_set_lines(
              buf,
              -1,
              -1,
              false,
              { 'Error: Could not parse current version' }
            )
            return
          end

          install_npm_packages_sequentially(
            buf,
            npm_packages,
            current_version,
            home_dir
          )
        end)
      end,
    })
    :start()
end

return M
