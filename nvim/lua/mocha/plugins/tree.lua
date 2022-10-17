local M = {
  plugins = {
    {
      'kyazdani42/nvim-tree.lua',
      requires = 'kyazdani42/nvim-web-devicons',
      config = function()
        require('nvim-tree').setup({
          view = {
            width = 40,
          },
        })
      end,
    },
  },
}

function M.after()
  local nmap = require('mocha.core.keymap').nmap
  nmap('<leader>e', '<cmd>NvimTreeFocus<cr>', { desc = 'Focus Tree' })
  nmap('<leader>te', '<cmd>NvimTreeToggle<cr>', { desc = 'Toggle Tree' })
end

return M
