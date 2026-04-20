return {
  src = "https://github.com/stevearc/oil.nvim",
  setup = function()
    require("oil").setup()
    vim.keymap.set("n", "-", "<cmd>Oil<cr>", { desc = "Open parent directory" })
  end,
}
