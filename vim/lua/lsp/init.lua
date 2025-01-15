-- NOTE:
-- Language servers written as npm / node package, can be installed with :InstallLspServers command

require 'lsp.handlers'
require 'lsp.formatting'

local utils = require 'util.utils'
local M = {}

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

  -- https://github.com/microsoft/pyright
  lspconfig.pyright.setup {
    on_attach = on_attach,
  }

  -- https://github.com/typescript-language-server/typescript-language-server
  lspconfig.ts_ls.setup {
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

  -- https://github.com/hrsh7th/vscode-langservers-extracted
  lspconfig.jsonls.setup {
    on_attach = on_attach,
    cmd = { 'vscode-json-language-server', '--stdio' },
    init_options = {
      provideFormatter = false, -- prefer prettier
    },
  }

  -- https://github.com/hrsh7th/vscode-langservers-extracted
  lspconfig.html.setup {
    on_attach = on_attach,
    init_options = {
      provideFormatter = false, -- prefer prettier
    },
  }

  -- https://github.com/hrsh7th/vscode-langservers-extracted
  lspconfig.cssls.setup {
    on_attach = on_attach,
    init_options = {
      provideFormatter = false, -- prefer prettier
    },
  }

  -- https://github.com/antonk52/cssmodules-language-server
  lspconfig.cssmodules_ls.setup {
    on_attach = function(client)
      -- avoid accepting `definitionProvider` responses from this LSP
      -- client.server_capabilities.definitionProvider = false
      on_attach(client)
    end,
  }

  -- https://github.com/vunguyentuan/vscode-css-variables/tree/master/packages/css-variables-language-server

  -- https://github.com/tailwindlabs/tailwindcss-intellisense
  lspconfig.tailwindcss.setup {
    on_attach = on_attach,
  }

  -- https://github.com/redhat-developer/yaml-language-server
  lspconfig.yamlls.setup {
    on_attach = on_attach,
    init_options = {
      provideFormatter = false, -- prefer prettier
    },
  }

  -- https://github.com/joe-re/sql-language-server
  lspconfig.sqlls.setup {
    on_attach = on_attach,
  }

  -- https://github.com/bash-lsp/bash-language-server
  lspconfig.bashls.setup {
    on_attach = on_attach,
  }

  -- https://github.com/rcjsuen/dockerfile-language-server-nodejs
  lspconfig.dockerls.setup {
    on_attach = on_attach,
  }

  -- https://github.com/microsoft/compose-language-service
  lspconfig.docker_compose_language_service.setup {
    on_attach = on_attach,
  }

  -- NOTE: not using 'typeprof' lsp as not currently using ruby's built-in type
  -- syntax, preferring sorbet/tapioca for now.

  -- NOTE: not using 'ruby_lsp', as it seems to not really work compared to
  -- sorbet lsp, and they probably conflict in some way

  -- https://github.com/sorbet/sorbet
  lspconfig.sorbet.setup {
    -- on_attach = on_attach,
    -- cmd = { 'bundle exec srb', 'tc', '--lsp' },
  }

  -- https://github.com/rubocop/rubocop
  lspconfig.rubocop.setup {
    on_attach = on_attach,
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

  -- https://www.npmjs.com/package/graphql-language-service-cli
  lspconfig.graphql.setup {
    on_attach = on_attach,
  }

  -- https://github.com/jose-elias-alvarez/null-ls.nvim
  --
  -- General purpose language server, useful for hooking up prettier
  --
  -- NOTE: This is no longer integrated or dependent on lspconfig
  --
  -- NOTE: no longer supported
  --
  local null_ls = require 'null-ls'

  null_ls.setup {
    -- register any number of sources simultaneously
    sources = {
      null_ls.builtins.formatting.prettier.with {
        filetypes = {
          'javascript',
          'javascriptreact',
          'typescript',
          'typescriptreact',
          'vue',
          'css',
          'scss',
          'less',
          'html',
          'json',
          'jsonc',
          'yaml',
          'markdown',
          'markdown.mdx',
          'graphql',
        }, -- removed 'handlebars' from the default prettier filetypes - causes issues when editing .hbs files
      },
      null_ls.builtins.formatting.stylua,
      null_ls.builtins.formatting.sqlformat,
    },
    on_attach = on_attach,
    -- debug = true,
  }

  -- https://github.com/hrsh7th/vscode-langservers-extracted
  lspconfig.eslint.setup {
    on_attach = on_attach,
    filetypes = {
      'javascript',
      'javascriptreact',
      'javascript.jsx',
      'typescript',
      'typescriptreact',
      'typescript.tsx',
      'vue',
      'svelte',
      'astro',
      'graphql',
    },
  }

  -- https://github.com/clangd/clangd
  lspconfig.clangd.setup {
    on_attach = on_attach,
  }

  -- https://github.com/rust-lang/rust-analyzer
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
