local nvim_lsp = require('lspconfig')
local util = nvim_lsp.util
local path = util.path
local lsp_attach = require('lsp.attach')

local function get_python_path()
  if vim.env.VIRTUAL_ENV then
    return path.join(vim.env.VIRTUAL_ENV, 'bin', 'python')
  end

  return vim.fn.exepath('python3') or vim.fn.exepath('python') or 'python'
end

return {
  on_attach = function(client, bufnr)
    client.server_capabilities.document_formatting = false
    client.server_capabilities.semanticTokensProvider = nil
  end,
  capabilities = lsp_attach.capabilities,
  settings = {
    ty = {
    },
  },
  before_init = function(_, config)
    local python_path = get_python_path()
    config.settings.python = config.settings.python or {}
    config.settings.python.pythonPath = python_path
    vim.notify(python_path)
  end,
}
