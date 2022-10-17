local err = require('mocha.core.lib.err')
local M = {
  on_attach = nil,
  capabilities = nil,
}

---Set the default diagnostic settings from all sources
local function set_lsp_diagnostic_config(opts)
  vim.diagnostic.config(opts)
end

---Set float options when invoked by LSP
local function set_lsp_float_opts(opts)
  vim.lsp.handlers['textDocument/hover'] = vim.lsp.with(vim.lsp.handlers.hover, opts)
  vim.lsp.handlers['textDocument/signatureHelp'] = vim.lsp.with(vim.lsp.handlers.signatureHelp, opts)
end

---Set autocompletion capabilities for each lsp server
local function set_lsp_completion_capabilities()
  -- LSP Default Capabilities
  M.capabilities = vim.lsp.protocol.make_client_capabilities()

  -- nvim-cmp Config
  -- ---
  local ok, nvim_cmp_lsp = pcall(require, 'cmp_nvim_lsp')

  if ok then
    M.capabilities = nvim_cmp_lsp.default_capabilities(vim.lsp.protocol.make_client_capabilities())
  else
    M.capabilities.textDocument.completion.completionItem.insertReplaceSupport = true
    M.capabilities.textDocument.completion.completionItem.preselectSupport = true
    M.capabilities.textDocument.completion.completionItem.snippetSupport = true
    M.capabilities.textDocument.completion.completionItem.resolveSupport = {
      properties = {
        'documentation',
        'detail',
        'additionalTextEdits',
      },
    }
  end
end

---Set LSP diagnostic signs
local function set_lsp_diagnostic_signs(opts)
  for type, icon in pairs(opts) do
    local hl = 'DiagnosticSign' .. type

    vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
  end
end

---Initialize default nvim-lsp settings
function M.init(opts)
  local defaults = {
    debug = false,
    float = {
      width = 80,
      border = 'rounded',
    },
    diagnostic = {
      signs = true,
      underline = true,
      update_in_insert = false,
      virtual_text = false,
    },
    signs = {
      Error = ' ',
      Warn = ' ',
      Hint = ' ',
      Info = ' ',
    },
  }

  if opts == nil or next(opts) == nil then
    opts = defaults
  else
    opts = vim.tbl_extend('force', defaults, opts)
  end

  set_lsp_diagnostic_signs(opts.signs)
  set_lsp_diagnostic_config(opts.diagnostic)
  set_lsp_float_opts(opts.float)
  set_lsp_completion_capabilities()

  -- Add on_attach
  if opts.on_attach then
    M.on_attach = opts.on_attach
  end

  if opts.debug then
    vim.lsp.set_log_level('debug')
  end
end

---Setup lsp server, given name and nvim-lsp configuration
function M.setup(server_name, opts)
  local defaults = {
    on_attach = M.on_attach,
    capabilities = M.capabilities,
  }

  opts = vim.tbl_extend('force', defaults, opts or {})

  local success, lspconfig = pcall(require, 'lspconfig')

  if not success then
    err('lspconfig: not installed')
    return
  end

  lspconfig[server_name].setup(opts)
end

return M
