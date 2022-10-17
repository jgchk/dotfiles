local M = {
  plugins = {

    -- Dependencies (Utilities)
    -- ------------------------

    -- Some lua plugins require plenary as a utility dependency like
    -- telescope.nvim
    { 'nvim-lua/plenary.nvim' },

    -- Core (What is essential - for me at least)
    -- ------------------------------------------

    -- Pretty much the standard plugin to have when working with teams that
    -- use different editors/IDEs, compliments nicely with my plugin above.
    { 'editorconfig/editorconfig-vim' },

    -- Lua plugin to automatically insert pairs like single-quote ('),
    -- double-quote ("), etc when in insert mode.
    { 'windwp/nvim-autopairs' },

    -- auto-close html tags
    { 'windwp/nvim-ts-autotag' },

    -- better matchit
    { 'andymass/vim-matchup' },

    -- Vim plugin to select text and surround them in quotes, parenthesis, etc,
    -- in normal/visual mode. Nothing much else to say, but this has been a very
    -- needed plugin for me.
    { 'tpope/vim-surround' },

    -- Vim plugin to repeat the above two plugins with the dot (.) operator.
    -- If you don't know the dot operator is used to repeat what changes you
    -- did in insert mode, but with this plugin you can now perform the
    -- the same for plugins that support vim-repeat API.
    { 'tpope/vim-repeat' },

    -- Adds Vim commands for common shell commands
    { 'tpope/vim-eunuch' },

    -- Infers shift width
    { 'tpope/vim-sleuth' },

    -- Easily align text with a pivot
    -- An example, if you have the following:
    --
    --   const hello = "Hello World"
    --   const ok = "ok world"
    --
    -- Easy align with = as pivot:
    --
    --   const hello = "Hello World"
    --   const ok    = "ok world"
    --
    { 'junegunn/vim-easy-align' },
  },
}

function M.after()
  -- nvim-autopairs Config
  -- ---
  require('nvim-autopairs').setup({})

  local xmap = require('mocha.core.keymap').xmap
  local nmap = require('mocha.core.keymap').nmap

  xmap('ga', '<Plug>(EasyAlign)')
  nmap('ga', '<Plug>(EasyAlign)')
end

return M
