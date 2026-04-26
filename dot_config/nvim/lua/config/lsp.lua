vim.lsp.enable("vtsls")

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

    vim.keymap.set("n", "]d", function() vim.diagnostic.jump({ count = 1, float = true }) end, { buf = bufnr, desc = "Next diagnostic" })
    vim.keymap.set("n", "[d", function() vim.diagnostic.jump({ count = -1, float = true }) end, { buf = bufnr, desc = "Prev diagnostic" })

    -- Enable auto-completion. Note: Use CTRL-Y to select an item. |complete_CTRL-Y|
    if client:supports_method('textDocument/completion') then
      -- Optional: trigger autocompletion on EVERY keypress. May be slow!
      local chars = {}; for i = 32, 126 do table.insert(chars, string.char(i)) end
      client.server_capabilities.completionProvider.triggerCharacters = chars
      vim.lsp.completion.enable(true, client.id, ev.buf, {autotrigger = true})
    end
  end,
})
