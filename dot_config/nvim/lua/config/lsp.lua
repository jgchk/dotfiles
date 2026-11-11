vim.lsp.enable("vtsls")
vim.lsp.enable("eslint")

-- Prefer a standalone rust-analyzer over the rustup proxy on PATH: it follows each
-- project's pinned toolchain without needing the component installed per toolchain.
local function find_rust_analyzer()
  for _, p in ipairs({ "/opt/homebrew/bin/rust-analyzer", "/usr/local/bin/rust-analyzer", "/usr/bin/rust-analyzer" }) do
    if vim.uv.fs_stat(p) then return p end
  end
  return "rust-analyzer"
end

vim.lsp.config("rust_analyzer", { cmd = { find_rust_analyzer() } })
vim.lsp.enable("rust_analyzer")

vim.opt.completeopt = { "menuone", "noselect", "popup" }

vim.keymap.set('i', '<Tab>', function()
  return vim.fn.pumvisible() == 1 and '<C-n>' or '<Tab>'
end, { expr = true })

vim.keymap.set('i', '<S-Tab>', function()
  return vim.fn.pumvisible() == 1 and '<C-p>' or '<S-Tab>'
end, { expr = true })

vim.keymap.set('i', '<CR>', function()
  if vim.fn.pumvisible() == 1 then
    local info = vim.fn.complete_info({ 'selected', 'items' })
    if info.selected >= 0 then
      return '<C-y>'                -- confirm already-selected item
    elseif #info.items == 1 then
      return '<C-n><C-y>'           -- only one option: select it then confirm
    end
  end
  return '<CR>'
end, { expr = true })

vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('my.lsp', {}),
  callback = function(ev)
    local client = assert(vim.lsp.get_client_by_id(ev.data.client_id))

    vim.keymap.set("n", "gd", vim.lsp.buf.definition, { buffer = ev.buf, desc = "Go to definition" })
    vim.keymap.set("n", "gr", vim.lsp.buf.references, { buffer = ev.buf, desc = "Go to references" })
    vim.keymap.set("n", "cr", vim.lsp.buf.rename, { buffer = ev.buf, desc = "Rename symbol" })
    vim.keymap.set("n", "]d", function() vim.diagnostic.jump({ count = 1, float = true }) end, { buffer = ev.buf, desc = "Next diagnostic" })
    vim.keymap.set("n", "[d", function() vim.diagnostic.jump({ count = -1, float = true }) end, { buffer = ev.buf, desc = "Prev diagnostic" })
    vim.keymap.set({ "n", "v" }, "ca", vim.lsp.buf.code_action, { buffer = ev.buf, desc = "Code actions" })

    -- Enable auto-completion. Note: Use CTRL-Y to select an item. |complete_CTRL-Y|
    if client:supports_method('textDocument/completion') then
      -- Optional: trigger autocompletion on EVERY keypress. May be slow!
      local chars = {}; for i = 32, 126 do table.insert(chars, string.char(i)) end
      client.server_capabilities.completionProvider.triggerCharacters = chars
      vim.lsp.completion.enable(true, client.id, ev.buf, {autotrigger = true})
    end
  end,
})
