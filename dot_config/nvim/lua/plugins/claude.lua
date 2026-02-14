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
    init = function()
      -- Terminal mode mappings to escape and navigate
      -- Double-escape exits terminal mode
      vim.keymap.set("t", "<Esc><Esc>", [[<C-\><C-n>]], { desc = "Exit terminal mode" })
      -- Allow window navigation from terminal mode with Ctrl-w prefix
      vim.keymap.set("t", "<C-w>h", [[<C-\><C-n><C-w>h]], { desc = "Go to left window" })
      vim.keymap.set("t", "<C-w>j", [[<C-\><C-n><C-w>j]], { desc = "Go to window below" })
      vim.keymap.set("t", "<C-w>k", [[<C-\><C-n><C-w>k]], { desc = "Go to window above" })
      vim.keymap.set("t", "<C-w>l", [[<C-\><C-n><C-w>l]], { desc = "Go to right window" })
      vim.keymap.set("t", "<C-w>w", [[<C-\><C-n><C-w>w]], { desc = "Go to next window" })
    end,
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
