local M = {
  plugins = {
    { 'nvim-treesitter/nvim-treesitter', run = ':TSUpdate' },
    { 'nvim-treesitter/nvim-treesitter-refactor' },
    { 'lukas-reineke/indent-blankline.nvim' },
    {
      'folke/which-key.nvim',
      config = function()
        require('which-key').setup({
          -- your configuration comes here
          -- or leave it empty to use the default settings
          -- refer to the configuration section below
        })
      end,
    },
    { 'akinsho/bufferline.nvim', tag = 'v3.*', requires = 'kyazdani42/nvim-web-devicons' },
    { 'nvim-lualine/lualine.nvim', requires = { 'kyazdani42/nvim-web-devicons' } },
  },
}

function M.after()
  require('nvim-treesitter.configs').setup({
    ensure_installed = {
      'css',
      'graphql',
      'html',
      'javascript',
      'typescript',
      'tsx',
      'prisma',
      'lua',
    },
    highlight = { enable = true },
    indent = { enable = false },
    refactor = {
      highlight_definitions = { enable = true },
    },
    context_commentstring = {
      enable = true,
      enable_autocmd = false,
    },
    matchup = {
      enable = true,
    },
    autotag = {
      enable = true,
    },
  })

  require('indent_blankline').setup({
    char = '▏',
  })

  require('bufferline').setup({
    options = {
      offsets = {
        {
          filetype = 'NvimTree',
          text = 'File Explorer',
          highlight = 'Directory',
          separator = true,
        },
        {
          filetype = 'packer',
          text = 'Packer',
          highlight = 'Directory',
          separator = true,
        },
      },
      diagnostics = 'nvim_lsp',
      diagnostics_indicator = function(count, level, diagnostics_dict, context)
        local icon = level:match('error') and ' ' or ' '
        return ' ' .. icon .. count
      end,
    },
  })

  require('lualine').setup({})
end

return M
