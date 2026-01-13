-- Claude Code integration
return {
  {
    "folke/which-key.nvim",
    optional = true,
    opts = {
      spec = {
        { "<leader>a", group = "ai" },
      },
    },
  },
  {
    dir = vim.fn.stdpath("config") .. "/lua/plugins",
    name = "claude-code",
    keys = {
      {
        "<leader>ac",
        function()
          local buf = vim.api.nvim_create_buf(false, true)
          local width = math.floor(vim.o.columns * 0.8)
          local height = math.floor(vim.o.lines * 0.8)

          local win = vim.api.nvim_open_win(buf, true, {
            relative = "editor",
            width = width,
            height = height,
            col = math.floor((vim.o.columns - width) / 2),
            row = math.floor((vim.o.lines - height) / 2),
            style = "minimal",
            border = "rounded",
          })

          vim.fn.termopen("claude /commit", {
            on_exit = function()
              if vim.api.nvim_win_is_valid(win) then
                vim.api.nvim_win_close(win, true)
              end
            end,
          })

          vim.cmd("startinsert")
        end,
        desc = "Claude commit",
      },
    },
  },
}
