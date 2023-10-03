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
        },
      },
    },
  },
  {
    "nvimtools/none-ls.nvim",
    opts = function(_)
      local nls = require("null-ls")
      nls.builtins.formatting.prettierd.with({
        extra_filetypes = { "svelte" },
      })
    end,
  },
}
