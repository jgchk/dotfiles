return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      -- make sure mason installs the server
      servers = {
        ---@type lspconfig.options.svelte
        svelte = {
          settings = {
            svelte = {
              format = {
                enable = false,
              },
            },
          },

          on_attach = function(client, bufnr)
            if client.name == "svelte" then
              vim.api.nvim_create_autocmd("BufWritePost", {
                pattern = { "*.js", "*.ts", "*.svelte" },
                callback = function(ctx)
                  client.notify("$/onDidChangeTsOrJsFile", { uri = ctx.file })
                end,
              })
            end
            if vim.bo[bufnr].filetype == "svelte" then
              vim.api.nvim_create_autocmd("BufWritePost", {
                pattern = { "*.js", "*.ts", "*.svelte" },
                callback = function(ctx)
                  client.notify("$/onDidChangeTsOrJsFile", { uri = ctx.file })
                end,
              })
            end
          end,
        },
      },
    },
  },
}
