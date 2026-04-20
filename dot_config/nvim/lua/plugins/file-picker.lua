return {
  src = "https://github.com/ibhagwan/fzf-lua",
  setup = function()
    vim.keymap.set("n", "<leader>ff", "<cmd>FzfLua files<cr>")
    vim.keymap.set("n", "<leader>sg", "<cmd>FzfLua live_grep<cr>")
  end,
}
