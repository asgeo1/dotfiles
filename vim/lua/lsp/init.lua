require 'lsp.handlers'
require 'lsp.formatting'
local utils = require 'util.utils'
local M = {}

vim.lsp.protocol.CompletionItemKind = {
  ' [text]',
  ' [method]',
  ' [function]',
  ' [constructor]',
  'ﰠ [field]',
  ' [variable]',
  ' [class]',
  ' [interface]',
  ' [module]',
  ' [property]',
  ' [unit]',
  ' [value]',
  ' [enum]',
  ' [key]',
  '﬌ [snippet]',
  ' [color]',
  ' [file]',
  ' [reference]',
  ' [folder]',
  ' [enum member]',
  ' [constant]',
  ' [struct]',
  '⌘ [event]',
  ' [operator]',
  ' [type]',
}

local signs = {
  Error = ' ',
  Warning = ' ',
  Hint = ' ',
  Information = ' ',
}

for type, icon in pairs(signs) do
  local hl = 'DiagnosticSign' .. type
  vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end

local on_attach = function(client)
  if client.server_capabilities.documentFormattingProvider then
    vim.cmd [[augroup Format]]
    vim.cmd [[autocmd! * <buffer>]]
    vim.cmd [[autocmd BufWritePost <buffer> lua require'lsp.formatting'.format_async()]]
    vim.cmd [[augroup END]]

    utils.map(
      'n',
      '<leader>af',
      "<cmd>lua require'lsp.formatting'.format_async()<CR>",
      { buffer = true }
    )
  end

  if client.server_capabilities.gotoDefinitionProvider then
    utils.map(
      'n',
      '<C-]>',
      '<cmd>lua vim.lsp.buf.definition()<CR>',
      { buffer = true }
    )
  end

  if client.server_capabilities.hoverProvider then
    utils.map('n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', { buffer = true })
  end

  if client.server_capabilities.findReferencesProvider then
    utils.map(
      'n',
      '<Space>*',
      ":lua require('lists').change_active('Quickfix')<CR>:lua vim.lsp.buf.references()<CR>",
      { buffer = true }
    )
  end

  if client.server_capabilities.renameProvider then
    utils.map(
      'n',
      '<Space>rn',
      "<cmd>lua require'lsp.rename'.rename()<CR>",
      { silent = true, buffer = true }
    )
  end

  utils.map(
    'n',
    '<Space><CR>',
    '<cmd>lua vim.diagnostic.open_float()<CR>',
    { buffer = true }
  )

  -- Signature help
  utils.map(
    'n',
    '<Space>sh',
    '<cmd>lua vim.lsp.buf.signature_help()<CR>',
    { buffer = true }
  )

  -- Perform code action
  utils.map(
    'n',
    '<Space>ca',
    '<cmd>lua vim.lsp.buf.code_action()<CR>',
    { buffer = true }
  )

  -- Next/Prev diagnostic issue
  utils.map(
    'n',
    '<Space>n',
    '<cmd>lua vim.diagnostic.goto_next()<CR>',
    { buffer = true }
  )
  utils.map(
    'n',
    '<Space>p',
    '<cmd>lua vim.diagnostic.goto_prev()<CR>',
    { buffer = true }
  )

  -- Send errors to the location list
  utils.map(
    'n',
    '<Space>ll',
    '<cmd>lua vim.diagnostic.setloclist({ open_loclist = false })<CR>',
    { buffer = true }
  )

  -- disabled for now, because of performance issues with `O`, `x`, `u` etc
  -- require "lsp_signature".on_attach()
end

function _G.activeLSP()
  local servers = {}
  for _, lsp in pairs(vim.lsp.get_active_clients()) do
    table.insert(servers, { name = lsp.name, id = lsp.id })
  end
  _G.P(servers)
end

function _G.bufferActiveLSP()
  local servers = {}
  for _, lsp in pairs(vim.lsp.buf_get_clients()) do
    table.insert(servers, { name = lsp.name, id = lsp.id })
  end
  _G.P(servers)
end

M.after_lazy_done = function()
  local lspconfig = require 'lspconfig'

  -- https://github.com/golang/tools/tree/master/gopls
  lspconfig.gopls.setup {
    on_attach = function(client)
      client.server_capabilities.documentFormattingProvider = false
      on_attach(client)
    end,
  }

  -- https://github.com/palantir/python-language-server
  -- lspconfig.pyls.setup {
  --     on_attach = on_attach,
  --     settings = {
  --         pyls = {
  --             plugins = {
  --                 pycodestyle = {
  --                     enabled = false,
  --                     ignore = {
  --                         "E501"
  --                     }
  --                 }
  --             }
  --         }
  --     }
  -- }

  lspconfig.pyright.setup {
    on_attach = on_attach,
  }

  -- https://github.com/theia-ide/typescript-language-server
  lspconfig.tsserver.setup {
    on_attach = function(client)
      client.server_capabilities.documentFormattingProvider = false
      require('nvim-lsp-ts-utils').setup {}
      on_attach(client)
    end,
  }

  local function get_lua_runtime()
    local result = {}
    for _, path in pairs(vim.api.nvim_list_runtime_paths()) do
      local lua_path = path .. '/lua/'
      if vim.fn.isdirectory(lua_path) then
        result[lua_path] = true
      end
    end

    result[vim.fn.expand '$VIMRUNTIME/lua'] = true
    -- result[vim.fn.expand("~/dev/neovim/src/nvim/lua")] = true

    return result
  end

  local system_name
  if vim.fn.has 'mac' == 1 then
    system_name = 'macOS'
  elseif vim.fn.has 'unix' == 1 then
    system_name = 'Linux'
  elseif vim.fn.has 'win32' == 1 then
    system_name = 'Windows'
  else
    print 'Unsupported system for sumneko'
  end

  -- local sumneko_root_path = vim.fn.stdpath('cache')..'/lspconfig/lua_ls/lua-language-server'
  local sumneko_root_path = vim.fn.expand '~/Projects/tools/lua-language-server'
  local sumneko_binary = sumneko_root_path
    .. '/bin/'
    .. system_name
    .. '/lua-language-server'

  lspconfig.lua_ls.setup {
    on_attach = on_attach,
    --cmd = {"lua-language-server"},
    cmd = { sumneko_binary, '-E', sumneko_root_path .. '/main.lua' },
    settings = {
      Lua = {
        runtime = {
          version = 'LuaJIT',
        },
        completion = {
          keywordSnippet = 'Disable',
        },
        diagnostics = {
          enable = true,
          globals = {
            -- Neovim
            'vim',
            -- Busted
            'describe',
            'it',
            'before_each',
            'after_each',
            'teardown',
            'pending',
            -- packer
            'use',
          },
          workspace = {
            library = get_lua_runtime(),
            maxPreload = 1000,
            preloadFileSize = 1000,
          },
          -- Do not send telemetry data containing a randomized but unique identifier
          telemetry = {
            enable = false,
          },
        },
      },
    },
  }

  -- https://github.com/iamcco/vim-language-server
  lspconfig.vimls.setup {
    on_attach = on_attach,
  }

  -- https://github.com/vscode-langservers/vscode-json-languageserver
  lspconfig.jsonls.setup {
    on_attach = on_attach,
    cmd = { 'vscode-json-language-server', '--stdio' },
    init_options = {
      provideFormatter = false,
    },
  }

  -- https://github.com/redhat-developer/yaml-language-server
  lspconfig.yamlls.setup {
    on_attach = on_attach,
    init_options = {
      provideFormatter = false,
    },
  }

  -- NOT WORKING due to error
  --
  -- ERROR: sqlls: config.cmd error, ...Cellar/neovim/0.5.1_1/share/nvim/runtime/lua/vim/lsp.lua:178: cmd: expected list, got nil
  -- stack traceback:
  -- ...Cellar/neovim/0.5.1_1/share/nvim/runtime/lua/vim/lsp.lua:178: in function <...Cellar/neovim/0.5.1_1/share/nvim/runtime/lua/vim/lsp.lua:177>
  -- [C]: in function 'pcall'
  -- ...ack/packer/start/nvim-lspconfig/lua/lspconfig/health.lua:11: in function 'check'
  -- [string ":lua"]:1: in main chunk
  --
  -- -- https://github.com/joe-re/sql-language-server
  -- lspconfig.sqlls.setup {
  --   on_attach = on_attach
  -- }

  -- https://github.com/vscode-langservers/vscode-css-languageserver-bin
  lspconfig.cssls.setup {
    on_attach = on_attach,
    init_options = {
      provideFormatter = false,
    },
  }

  -- https://github.com/vscode-langservers/vscode-html-languageserver-bin
  lspconfig.html.setup {
    on_attach = on_attach,
    init_options = {
      provideFormatter = false,
    },
  }

  -- https://github.com/bash-lsp/bash-language-server
  lspconfig.bashls.setup {
    on_attach = on_attach,
  }

  -- https://github.com/rcjsuen/dockerfile-language-server-nodejs
  lspconfig.dockerls.setup {
    on_attach = on_attach,
  }

  -- NOTE: paid alternative is https://intelephense.com/
  --
  -- https://solargraph.org/
  -- lspconfig.solargraph.setup {
  --   on_attach = on_attach,
  --   settings = {
  --     solargraph = {
  --       formatting = true,
  --       diagnostics = true,
  --     },
  --   },
  --   init_options = {
  --     documentFormatting = true,
  --     provideFormatter = true,
  --   },
  -- }

  -- Seems slow
  --
  -- Mostly useful to integrate Rubocop with the Neovim, though doesn't seem to
  -- work currently
  --
  -- https://shopify.github.io/ruby-lsp/
  -- lspconfig.ruby_ls.setup {
  -- on_attach = on_attach,
  -- cmd = { 'bundle', 'exec', 'ruby-lsp' },
  -- }

  lspconfig.sorbet.setup {
    -- on_attach = on_attach,
    -- cmd = { 'bundle exec srb', 'tc', '--lsp' },
  }

  -- https://github.com/phpactor/phpactor
  lspconfig.phpactor.setup {
    on_attach = on_attach,
  }

  -- https://github.com/hashicorp/terraform-ls
  lspconfig.terraformls.setup {
    on_attach = on_attach,
    cmd = { 'terraform-ls', 'serve' },
    filetypes = { 'tf' },
  }

  -- General purpose language server, useful for hooking up prettier
  --
  -- NOTE: This is no longer integrated or dependent on lspconfig
  --
  local null_ls = require 'null-ls'

  null_ls.setup {
    -- register any number of sources simultaneously
    sources = {
      null_ls.builtins.diagnostics.rubocop,
      null_ls.builtins.formatting.rubocop,
      -- Using prettier rather than prettierd, as prettierd doesn't seem to support ESM config files very well, nor does it seem to work with tail
      -- null_ls.builtins.formatting.prettier,
      null_ls.builtins.formatting.prettier,
      null_ls.builtins.formatting.stylua,
      null_ls.builtins.formatting.sqlformat,
    },
    on_attach = on_attach,
    -- debug = true,
  }

  -- https://github.com/hrsh7th/vscode-langservers-extracted
  lspconfig.eslint.setup {
    on_attach = on_attach,
  }

  lspconfig.clangd.setup {
    on_attach = on_attach,
  }

  lspconfig.cssmodules_ls.setup {
    on_attach = function(client)
      -- avoid accepting `definitionProvider` responses from this LSP
      -- client.server_capabilities.definitionProvider = false
      on_attach(client)
    end,
  }

  lspconfig.rust_analyzer.setup {
    settings = {
      ['rust-analyzer'] = {
        diagnostics = {
          enable = false,
        },
      },
    },
  }
end

return M
