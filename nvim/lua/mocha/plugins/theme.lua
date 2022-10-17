local M = {
  plugins = {
    -- Theme Utils
    {
      'NvChad/nvim-colorizer.lua',
      config = function()
        require('colorizer').setup({
          tailwind = true,
        })
        require('colorizer').attach_to_buffer(0)
      end,
    },

    -- Themes
    {
      'ellisonleao/gruvbox.nvim',
      config = function()
        require('gruvbox').setup()
        vim.cmd('colorscheme gruvbox')
      end,
    },
  },
}

return M
