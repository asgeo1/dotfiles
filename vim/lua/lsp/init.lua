require "lsp.handlers"
require "lsp.formatting"
local lspconfig = require "lspconfig"
local utils = require "utils"
local M = {}

vim.lsp.protocol.CompletionItemKind = {
  " [text]",
  " [method]",
  " [function]",
  " [constructor]",
  "ﰠ [field]",
  " [variable]",
  " [class]",
  " [interface]",
  " [module]",
  " [property]",
  " [unit]",
  " [value]",
  " [enum]",
  " [key]",
  "﬌ [snippet]",
  " [color]",
  " [file]",
  " [reference]",
  " [folder]",
  " [enum member]",
  " [constant]",
  " [struct]",
  "⌘ [event]",
  " [operator]",
  " [type]"
}

M.symbol_kind_icons = {
  Function = "",
  Method = "",
  Variable = "",
  Constant = "",
  Interface = "",
  Field = "ﰠ",
  Property = "",
  Struct = "",
  Enum = "",
  Class = ""
}

M.symbol_kind_colors = {
  Function = "green",
  Method = "green",
  Variable = "blue",
  Constant = "red",
  Interface = "cyan",
  Field = "blue",
  Property = "blue",
  Struct = "cyan",
  Enum = "yellow",
  Class = "red"
}



local signs = {
  Error = " ",
  Warning = " ",
  Hint = " ",
  Information = " "
}

for type, icon in pairs(signs) do
  local hl = "DiagnosticSign" .. type
  vim.fn.sign_define(hl, {text = icon, texthl = hl, numhl = hl})
end



local on_attach = function(client)
  if client.resolved_capabilities.document_formatting then
    vim.cmd [[augroup Format]]
    vim.cmd [[autocmd! * <buffer>]]
    vim.cmd [[autocmd BufWritePost <buffer> lua require'lsp.formatting'.format_async()]]
    vim.cmd [[augroup END]]

    utils.map("n", "<leader>af", "<cmd>lua require'lsp.formatting'.format_async()<CR>", {buffer = true})
  end

  if client.resolved_capabilities.goto_definition then
    utils.map("n", "<C-]>", "<cmd>lua vim.lsp.buf.definition()<CR>", {buffer = true})
  end

  if client.resolved_capabilities.hover then
    utils.map("n", "K", "<cmd>lua vim.lsp.buf.hover()<CR>", {buffer = true})
  end

  if client.resolved_capabilities.find_references then
    utils.map(
      "n",
      "<Space>*",
      ":lua require('lists').change_active('Quickfix')<CR>:lua vim.lsp.buf.references()<CR>",
      {buffer = true}
    )
  end

  if client.resolved_capabilities.rename then
    utils.map("n", "<Space>rn", "<cmd>lua require'lsp.rename'.rename()<CR>", {silent = true, buffer = true})
  end

  utils.map("n", "<Space><CR>", "<cmd>lua require'lsp.diagnostics'.line_diagnostics()<CR>", {buffer = true})
  utils.map("n", "<Space>sh", "<cmd>lua vim.lsp.buf.signature_help()<CR>", {buffer = true})
  utils.map("n", "<Space>ca", "<cmd>lua vim.lsp.buf.code_action()<CR>", {buffer = true})

  -- Next/Prev diagnostic issue
  utils.map("n", "<Space>n", "<cmd>lua vim.lsp.diagnostic.goto_next()<CR>", {buffer = true})
  utils.map("n", "<Space>p", "<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>", {buffer = true})

  -- disabled for now, because of performance issues with `O`, `x`, `u` etc
  -- require "lsp_signature".on_attach()
end

local capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities())

function _G.activeLSP()
  local servers = {}
  for _, lsp in pairs(vim.lsp.get_active_clients()) do
      table.insert(servers, {name = lsp.name, id = lsp.id})
  end
  _G.P(servers)
end

function _G.bufferActiveLSP()
  local servers = {}
  for _, lsp in pairs(vim.lsp.buf_get_clients()) do
    table.insert(servers, {name = lsp.name, id = lsp.id})
  end
  _G.P(servers)
end

-- https://github.com/golang/tools/tree/master/gopls
lspconfig.gopls.setup {
  capabilities = capabilities,
  on_attach = function(client)
    client.resolved_capabilities.document_formatting = false
    on_attach(client)
  end
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
  capabilities = capabilities,
  on_attach = on_attach
}

-- https://github.com/theia-ide/typescript-language-server
lspconfig.tsserver.setup {
  capabilities = capabilities,
  on_attach = function(client)
    -- disable formatting, as this is being handled by prettier
    client.resolved_capabilities.document_formatting = false
    require "nvim-lsp-ts-utils".setup {}
    on_attach(client)
  end
}

local function get_lua_runtime()
  local result = {}
  for _, path in pairs(vim.api.nvim_list_runtime_paths()) do
    local lua_path = path .. "/lua/"
    if vim.fn.isdirectory(lua_path) then
      result[lua_path] = true
    end
  end

  result[vim.fn.expand("$VIMRUNTIME/lua")] = true
  -- result[vim.fn.expand("~/dev/neovim/src/nvim/lua")] = true

  return result
end

local system_name
if vim.fn.has("mac") == 1 then
  system_name = "macOS"
elseif vim.fn.has("unix") == 1 then
  system_name = "Linux"
elseif vim.fn.has('win32') == 1 then
  system_name = "Windows"
else
  print("Unsupported system for sumneko")
end

-- local sumneko_root_path = vim.fn.stdpath('cache')..'/lspconfig/sumneko_lua/lua-language-server'
local sumneko_root_path = vim.fn.expand("~/Projects/tools/lua-language-server")
local sumneko_binary = sumneko_root_path.."/bin/"..system_name.."/lua-language-server"

lspconfig.sumneko_lua.setup {
  capabilities = capabilities,
  on_attach = on_attach,
  --cmd = {"lua-language-server"},
  cmd = {sumneko_binary, "-E", sumneko_root_path .. "/main.lua"},
  settings = {
    Lua = {
      runtime = {
        version = "LuaJIT"
      },
      completion = {
        keywordSnippet = "Disable"
      },
      diagnostics = {
        enable = true,
        globals = {
          -- Neovim
          "vim",
          -- Busted
          "describe",
          "it",
          "before_each",
          "after_each",
          "teardown",
          "pending",
          -- packer
          "use"
        },
        workspace = {
          library = get_lua_runtime(),
          maxPreload = 1000,
          preloadFileSize = 1000
        },
        -- Do not send telemetry data containing a randomized but unique identifier
        telemetry = {
          enable = false,
        }
      }
    }
  }
}

-- https://github.com/iamcco/vim-language-server
lspconfig.vimls.setup {
  capabilities = capabilities,
  on_attach = on_attach
}

-- https://github.com/vscode-langservers/vscode-json-languageserver
lspconfig.jsonls.setup {
  capabilities = capabilities,
  on_attach = on_attach,
  cmd = {"vscode-json-language-server", "--stdio"}
}

-- https://github.com/redhat-developer/yaml-language-server
lspconfig.yamlls.setup {
  capabilities = capabilities,
  on_attach = on_attach
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
--   capabilities = capabilities,
--   on_attach = on_attach
-- }

-- https://github.com/vscode-langservers/vscode-css-languageserver-bin
lspconfig.cssls.setup {
  capabilities = capabilities,
  on_attach = on_attach
}

-- https://github.com/vscode-langservers/vscode-html-languageserver-bin
lspconfig.html.setup {
  capabilities = capabilities,
  on_attach = on_attach
}

-- https://github.com/bash-lsp/bash-language-server
lspconfig.bashls.setup {
  capabilities = capabilities,
  on_attach = on_attach
}

-- https://github.com/rcjsuen/dockerfile-language-server-nodejs
lspconfig.dockerls.setup {
  capabilities = capabilities,
  on_attach = on_attach
}

-- NOTE: paid alternative is https://intelephense.com/
--
-- https://solargraph.org/
lspconfig.solargraph.setup {
  capabilities = capabilities,
  on_attach = on_attach,
  settings = {
    solargraph = {
      formatting = true,
      diagnostics = true
    }
  },
  init_options = {
    documentFormatting = true,
    provideFormatter = true
  }
}

-- DISABLED for now, as can't install/compile PHP on arm64 for some reason
--
-- https://github.com/phpactor/phpactor
-- lspconfig.phpactor.setup {
--   capabilities = capabilities,
--   on_attach = on_attach
-- }

-- https://github.com/hashicorp/terraform-ls
lspconfig.terraformls.setup {
  capabilities = capabilities,
  on_attach = on_attach,
  cmd = {"terraform-ls", "serve"},
  filetypes = {"tf"}
}

local prettier = require "efm/prettier"
local eslint = require "efm/eslint"
local jq = require "efm/jq"
-- https://github.com/mattn/efm-langserver
lspconfig.efm.setup {
  -- custom cmd, for debugging:
  cmd = {'efm-langserver', '-logfile', '/tmp/efm.log', '-loglevel', '10'},

  capabilities = capabilities,
  on_attach = on_attach,
  init_options = {documentFormatting = true},
  root_dir = vim.loop.cwd,
  filetypes = {'typescript', 'javascript', 'typescriptreact', 'javascriptreact', 'yaml',
  'json',
  'html', 'scss', 'css', 'markdown'},
  settings = {
    rootMarkers = {".git/"},
    languages = {
      typescript = {prettier, eslint},
      javascript = {prettier, eslint},
      typescriptreact = {prettier, eslint},
      javascriptreact = {prettier, eslint},
      yaml = {prettier},
      -- formatting with prettier from stdin not working for json. Use jq in meantime as this supports this.
      -- doesn't make sense, as html is working :-/
      json = {jq},
      -- json = {prettier},
      html = {prettier},
      scss = {prettier},
      css = {prettier},
      markdown = {prettier}
    }
  }
}

lspconfig.clangd.setup {
  capabilities = capabilities,
  on_attach = on_attach
}

return M
