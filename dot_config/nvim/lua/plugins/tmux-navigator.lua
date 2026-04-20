return {
  src = "https://github.com/christoomey/vim-tmux-navigator",
  version = "master",
  setup = function()
    vim.g.tmux_navigator_no_mappings = 1
    vim.keymap.set({ "n", "t" }, "<C-h>", "<cmd>TmuxNavigateLeft<cr>", { silent = true })
    vim.keymap.set({ "n", "t" }, "<C-j>", "<cmd>TmuxNavigateDown<cr>", { silent = true })
    vim.keymap.set({ "n", "t" }, "<C-k>", "<cmd>TmuxNavigateUp<cr>", { silent = true })
    vim.keymap.set({ "n", "t" }, "<C-l>", "<cmd>TmuxNavigateRight<cr>", { silent = true })
  end,
}
