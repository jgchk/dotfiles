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
}
