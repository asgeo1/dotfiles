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

vim.fn.sign_define("LspDiagnosticsSignError", {text = "", numhl = "LspDiagnosticsDefaultError"})
vim.fn.sign_define("LspDiagnosticsSignWarning", {text = "", numhl = "LspDiagnosticsDefaultWarning"})
vim.fn.sign_define("LspDiagnosticsSignInformation", {text = "", numhl = "LspDiagnosticsDefaultInformation"})
vim.fn.sign_define("LspDiagnosticsSignHint", {text = "", numhl = "LspDiagnosticsDefaultHint"})

local on_attach = function(client)
    if client.resolved_capabilities.document_formatting then
        vim.cmd [[augroup Format]]
        vim.cmd [[autocmd! * <buffer>]]
        vim.cmd [[autocmd BufWritePost <buffer> lua require'lsp.formatting'.format()]]
        vim.cmd [[augroup END]]

        -- not working
        -- utils.map("n", "<leader>af", "<cmd>lua vim.lsp.buf.formatting()<CR>", {buffer = true})
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

    -- Next/Prev diagnostic issue
    utils.map("n", "<Space>n", "<cmd>lua vim.lsp.diagnostic.goto_next()<CR>", {buffer = true})
    utils.map("n", "<Space>p", "<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>", {buffer = true})


    -- disabled for now, because of performance issues with `O`, `x`, `u` etc
    -- require "lsp_signature".on_attach()
end

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

lspconfig.pyright.setup {on_attach = on_attach}

-- https://github.com/theia-ide/typescript-language-server
lspconfig.tsserver.setup {
    on_attach = function(client)
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
lspconfig.vimls.setup {on_attach = on_attach}

-- https://github.com/vscode-langservers/vscode-json-languageserver
lspconfig.jsonls.setup {
    on_attach = function(client)
        client.resolved_capabilities.document_formatting = false
        on_attach(client)
    end,
    cmd = {"vscode-json-language-server", "--stdio"}
}

-- https://github.com/redhat-developer/yaml-language-server
lspconfig.yamlls.setup {on_attach = on_attach}

-- https://github.com/joe-re/sql-language-server
lspconfig.sqlls.setup {on_attach = on_attach}

-- https://github.com/vscode-langservers/vscode-css-languageserver-bin
lspconfig.cssls.setup {on_attach = on_attach}

-- https://github.com/vscode-langservers/vscode-html-languageserver-bin
lspconfig.html.setup {on_attach = on_attach}

-- https://github.com/bash-lsp/bash-language-server
lspconfig.bashls.setup {on_attach = on_attach}

-- https://github.com/rcjsuen/dockerfile-language-server-nodejs
lspconfig.dockerls.setup {on_attach = on_attach}

-- NOTE: paid alternative is https://intelephense.com/
--
-- https://solargraph.org/
lspconfig.solargraph.setup {
  on_attach = on_attach,
  settings = {
    solargraph = {
      -- TODO: formatting not working
      formatting = true,
      diagnostics = false -- for now, turn off diagnostics, too anoying unless there is a way to bulk-correct issues easily
    }
  },
  init_options = {
    documentFormatting = true,
    provideFormatter = true
  }
}

-- https://github.com/phpactor/phpactor
lspconfig.phpactor.setup {on_attach = on_attach}

-- https://github.com/hashicorp/terraform-ls
lspconfig.terraformls.setup {
    on_attach = on_attach,
    cmd = {"terraform-ls", "serve"},
    filetypes = {"tf"}
}

local prettier = require "efm/prettier"
local eslint = require "efm/eslint"
-- https://github.com/mattn/efm-langserver
lspconfig.efm.setup {
    on_attach = on_attach,
    init_options = {documentFormatting = true},
    root_dir = vim.loop.cwd,
    filetypes = {'typescript', 'javascript', 'typescriptreact', 'javascriptreact', 'yaml', 'json', 'html', 'scss', 'css', 'markdown'},
    settings = {
        rootMarkers = {".git/"},
        languages = {
            typescript = {prettier, eslint},
            javascript = {prettier, eslint},
            typescriptreact = {prettier, eslint},
            javascriptreact = {prettier, eslint},
            yaml = {prettier},
            json = {prettier},
            html = {prettier},
            scss = {prettier},
            css = {prettier},
            markdown = {prettier}
        }
    }
}

lspconfig.clangd.setup {on_attach = on_attach}

return M
