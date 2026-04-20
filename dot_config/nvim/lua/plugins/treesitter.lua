local languages = {
  "bash",
  "lua",
  "markdown",
  "clojure",
  "typescript",
}

return {
  src = "https://github.com/nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  setup = function()
    require("nvim-treesitter").setup()

    require("nvim-treesitter").install(languages)

    -- Enable treesitter highlighting for all languages
    vim.api.nvim_create_autocmd("FileType", {
      pattern = languages,
      callback = function() vim.treesitter.start() end,
    })
  end,
}
