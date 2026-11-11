return {
  src = "https://github.com/stevearc/conform.nvim",
  setup = function()
    require("conform").setup({
      formatters_by_ft = {
        javascript = { "prettier" },
        typescript = { "prettier" },
        markdown = { "prettier" },
        rust = { "rustfmt" },
        cucumber = { "reformat_gherkin" },
      },
      formatters = {
        reformat_gherkin = {
          command = "reformat-gherkin",
          args = { "-" },
          stdin = true,
        },
      },
      format_on_save = {
        -- These options will be passed to conform.format()
        timeout_ms = 2000,
        lsp_format = "fallback",
      },
    })
  end,
}

