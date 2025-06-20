-- Shared LSP server configuration
local M = {}

-- NPM-based LSP servers that can be installed via :InstallLspServers
M.npm_packages = {
  ['typescript-language-server'] = { name = 'TypeScript', lsp_name = 'ts_ls' },
  ['vscode-langservers-extracted'] = { name = 'HTML/CSS/JSON/ESLint', lsp_name = 'multiple' },
  ['cssmodules-language-server'] = { name = 'CSS Modules', lsp_name = 'cssmodules_ls' },
  ['css-variables-language-server'] = { name = 'CSS Variables', lsp_name = 'css_variables' },
  ['vim-language-server'] = { name = 'VimScript', lsp_name = 'vimls' },
  ['sql-language-server'] = { name = 'SQL', lsp_name = 'sqlls' },
  ['bash-language-server'] = { name = 'Bash', lsp_name = 'bashls' },
  ['dockerfile-language-server-nodejs'] = { name = 'Dockerfile', lsp_name = 'dockerls' },
  ['@microsoft/compose-language-service'] = { name = 'Docker Compose', lsp_name = 'docker_compose_language_service' },
  ['pyright'] = { name = 'Python', lsp_name = 'pyright' },
  ['yaml-language-server'] = { name = 'YAML', lsp_name = 'yamlls' },
  ['@tailwindcss/language-server'] = { name = 'Tailwind CSS', lsp_name = 'tailwindcss' },
  ['graphql-language-service-cli'] = { name = 'GraphQL', lsp_name = 'graphql' },
}

-- Additional npm packages that aren't LSP servers but are useful
M.npm_utilities = {
  'neovim',
}

-- Manually installed LSP servers
M.manual_servers = {
  { name = 'Go', lsp_name = 'gopls', check_cmd = 'gopls version' },
  { name = 'Lua', lsp_name = 'lua_ls', check_cmd = 'lua-language-server --version' },
  { name = 'PHP (intelephense)', lsp_name = 'intelephense', check_cmd = 'intelephense --version' },
  { name = 'PHP (phpactor)', lsp_name = 'phpactor', check_cmd = 'phpactor --version' },
  { name = 'Ruby (solargraph)', lsp_name = 'solargraph', check_cmd = 'solargraph -v' },
  { name = 'Ruby (sorbet)', lsp_name = 'sorbet', check_cmd = 'srb --version' },
  { name = 'Ruby (rubocop)', lsp_name = 'rubocop', check_cmd = 'rubocop --version' },
  { name = 'Terraform', lsp_name = 'terraformls', check_cmd = 'terraform-ls --version' },
  { name = 'C/C++ (clangd)', lsp_name = 'clangd', check_cmd = 'clangd --version' },
  { name = 'Rust', lsp_name = 'rust_analyzer', check_cmd = 'rust-analyzer --version' },
}

-- Get list of all npm packages to install (LSP + utilities)
M.get_all_npm_packages = function()
  local packages = {}
  for package, _ in pairs(M.npm_packages) do
    table.insert(packages, package)
  end
  for _, package in ipairs(M.npm_utilities) do
    table.insert(packages, package)
  end
  return packages
end

return M