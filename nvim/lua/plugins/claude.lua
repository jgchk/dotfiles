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
    "nvim-neo-tree/neo-tree.nvim",
    optional = true,
    opts = {
      open_files_do_not_replace_types = { "trouble", "qf", "edgy" }, -- removed "terminal"
    },
  },
  {
    dir = vim.fn.stdpath("config") .. "/lua/plugins",
    name = "claude-code",
    keys = {
      {
        "<leader>ac",
        function()
          -- Switch to a normal window if in a special buffer (neo-tree, etc.)
          if vim.bo.filetype == "neo-tree" or vim.bo.buftype ~= "" then
            vim.cmd("wincmd p")
          end
          vim.cmd("enew")
          vim.bo.modified = false
          vim.fn.termopen("claude")
          vim.bo.buflisted = true
          vim.bo.bufhidden = "hide"
          vim.cmd("startinsert")
        end,
        desc = "Claude Code",
      },
      {
        "<leader>aC",
        function()
          if vim.bo.filetype == "neo-tree" or vim.bo.buftype ~= "" then
            vim.cmd("wincmd p")
          end
          vim.cmd("enew")
          vim.bo.modified = false
          vim.fn.termopen("claude --continue")
          vim.bo.buflisted = true
          vim.bo.bufhidden = "hide"
          vim.cmd("startinsert")
        end,
        desc = "Claude Code (continue)",
      },
      {
        "<leader>ar",
        function()
          if vim.bo.filetype == "neo-tree" or vim.bo.buftype ~= "" then
            vim.cmd("wincmd p")
          end
          vim.cmd("enew")
          vim.bo.modified = false
          vim.fn.termopen("claude --resume")
          vim.bo.buflisted = true
          vim.bo.bufhidden = "hide"
          vim.cmd("startinsert")
        end,
        desc = "Claude Code (resume)",
      },
    },
  },
}
