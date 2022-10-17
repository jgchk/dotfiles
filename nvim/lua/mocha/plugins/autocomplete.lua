local M = {
  plugins = {
    { 'hrsh7th/nvim-cmp' },
    { 'hrsh7th/cmp-nvim-lsp' },
    { 'hrsh7th/cmp-nvim-lua' },
    { 'hrsh7th/cmp-path' },
    { 'hrsh7th/cmp-buffer' },
    { 'saadparwaiz1/cmp_luasnip' },
    { 'onsails/lspkind-nvim' },
  },
}

function M.after()
  require('luasnip.loaders.from_vscode').lazy_load()

  local cmp = require('cmp')
  cmp.setup({
    snippet = {
      expand = function(args)
        require('luasnip').lsp_expand(args.body)
      end,
    },

    mapping = {
      ['<C-Space>'] = cmp.mapping.complete(),
      ['<C-y>'] = cmp.mapping.confirm({ select = true }),
      ['<Tab>'] = cmp.mapping.confirm({ select = true }),
      ['<C-n>'] = cmp.mapping.select_next_item(),
      ['<C-p>'] = cmp.mapping.select_prev_item(),
      ['<C-b>'] = cmp.mapping.scroll_docs(-4),
      ['<C-f>'] = cmp.mapping.scroll_docs(4),
    },

    -- You should specify your *installed* sources.
    sources = cmp.config.sources({
      { name = 'nvim_lsp' },
      { name = 'nvim_lua' },
      { name = 'path' },
      { name = 'luasnip' },
      { name = 'buffer' },
    }),

    formatting = {
      format = require('lspkind').cmp_format({
        with_text = true,
        menu = {
          buffer = '[B]',
          nvim_lsp = '[LS]',
        },
      }),
    },

    window = {
      documentation = {
        max_width = 80,
        border = 'rounded',
      },
    },
  })
end

return M
