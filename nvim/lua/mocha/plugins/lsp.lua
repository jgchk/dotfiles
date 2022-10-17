local M = {
  plugins = {
    {
      'williamboman/mason.nvim',
      'williamboman/mason-lspconfig.nvim',
      'neovim/nvim-lspconfig',
    },
    {
      'jose-elias-alvarez/null-ls.nvim',
      requires = {
        'nvim-lua/plenary.nvim',
        'neovim/nvim-lspconfig',
      },
    },
    {
      'folke/trouble.nvim',
      requires = 'kyazdani42/nvim-web-devicons',
    },
    {
      'glepnir/lspsaga.nvim',
      requires = {
        'neovim/nvim-lspconfig',
      },
    },
  },
}

function M.after()
  require('mason').setup()
  require('mason-lspconfig').setup()

  require('trouble').setup()

  require('lspsaga').init_lsp_saga()
  require('which-key').register({
    ['<leader>a'] = { '<cmd>Lspsaga code_action<cr>', 'Show code actions', silent = true },
    ['rn'] = { '<cmd>Lspsaga rename<cr>', 'Rename', silent = true },
    ['gd'] = { '<cmd>Lspsaga peek_definition<cr>', 'Peek definition', silent = true },
    ['gh'] = { '<cmd>Lspsaga lsp_finder<cr>', 'Peek references', silent = true },
    ['<leader>cd'] = { '<cmd>Lspsaga show_line_diagnostics<cr>', 'Show line diagnostics', silent = true },
    ['[e'] = {
      function()
        require('lspsaga.diagnostic').goto_prev()
      end,
      'Previous diagnostic',
      silent = true,
    },
    [']e'] = {
      function()
        require('lspsaga.diagnostic').goto_next()
      end,
      'Next diagnostic',
      silent = true,
    },
    ['[E'] = {
      function()
        require('lspsaga.diagnostic').goto_prev({ severity = vim.diagnostic.severity.ERROR })
      end,
      'Previous error',
      silent = true,
    },
    [']E'] = {
      function()
        require('lspsaga.diagnostic').goto_next({ severity = vim.diagnostic.severity.ERROR })
      end,
      'Next error',
      silent = true,
    },
    K = { '<cmd>Lspsaga hover_doc<cr>', 'Show documentation', silent = true },
    ['<leader>li'] = { '<cmd>LspInfo<cr>', 'Open LSP Info' },
  })

  ---Only call the formatting request for the given servers
  ---Ref: https://github.com/neovim/nvim-lspconfig/wiki/Multiple-language-servers-FAQ
  local custom_lsp_fmt = function(client, bufnr)
    local servers = { 'null-ls' }

    local fmt_fn = function()
      local fmt_params = vim.lsp.util.make_formatting_params({})
      client.request('textDocument/formatting', fmt_params, nil, bufnr)
    end

    if vim.tbl_contains(servers, client.name) then
      require('which-key').register({
        ['<leader>fo'] = { fmt_fn, 'Format', buffer = bufnr },
      })

      require('mocha.core.event').augroup('LspFormat', {
        {
          event = { 'BufWritePre' },
          exec = fmt_fn,
          buffer = bufnr,
        },
      })
    end
  end

  ---LSP on_attach to set configurations that are specific to the each LSP
  ---server
  local on_attach = function(client, bufnr)
    custom_lsp_fmt(client, bufnr)
  end

  -- Intialize lspconfig, to be used with nvimlsp.setup()
  local nvimlsp = require('mocha.core.lsp')
  nvimlsp.init({
    on_attach = on_attach,
    -- debug = true,
  })

  local null_ls = require('null-ls')
  null_ls.setup({
    sources = {
      -- lua
      null_ls.builtins.formatting.stylua,
      null_ls.builtins.diagnostics.selene,

      -- js/ts
      null_ls.builtins.formatting.prettierd,

      -- prisma
      -- null_ls.builtins.formatting.prismaFmt,

      -- bash
      null_ls.builtins.formatting.shfmt,
      null_ls.builtins.formatting.shellharden,
      null_ls.builtins.code_actions.shellcheck,
    },
    on_attach = on_attach,
  })

  -- Server Setup
  nvimlsp.setup('sumneko_lua', {
    settings = {
      Lua = {
        diagnostics = {
          globals = { 'vim' },
        },
        telemetry = {
          enable = false,
        },
      },
    },
  })

  nvimlsp.setup('tsserver')
  nvimlsp.setup('eslint')
  nvimlsp.setup('tailwindcss')
  nvimlsp.setup('prismals')

  nvimlsp.setup('bashls')
end

return M
