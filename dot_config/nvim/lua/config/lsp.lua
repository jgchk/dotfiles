vim.lsp.enable("vtsls")

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local bufnr = args.buf
    local client = vim.lsp.get_client_by_id(args.data.client_id)

    vim.keymap.set("n", "<leader>cr", vim.lsp.buf.rename, { buf = bufnr, desc = "Rename symbol" })
    vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, { buf = bufnr, desc = "Code action" })
    vim.keymap.set("n", "<leader>cd", vim.diagnostic.open_float, { buf = bufnr, desc = "Line diagnostics" })
    vim.keymap.set("n", "]d", function() vim.diagnostic.jump({ count = 1, float = true }) end, { buf = bufnr, desc = "Next diagnostic" })
    vim.keymap.set("n", "[d", function() vim.diagnostic.jump({ count = -1, float = true }) end, { buf = bufnr, desc = "Prev diagnostic" })

    if client and client:supports_method("textDocument/completion") then
      vim.lsp.completion.enable(true, client.id, bufnr, { autotrigger = true })
    end
  end,
})
