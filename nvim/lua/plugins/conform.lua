return {
  "stevearc/conform.nvim",
  opts = {
    formatters_by_ft = {
      zsh = { "beautysh" },
    },
    ---@type table<string, conform.FormatterConfigOverride|fun(bufnr: integer): nil|conform.FormatterConfigOverride>
    formatters = {},
  },
}
