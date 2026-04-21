-- Use system clipboard
vim.opt.clipboard = "unnamedplus"

-- Line numbers: absolute on current line, relative on others
vim.opt.number = true
vim.opt.relativenumber = true

-- Disable netrw (must be set before plugins load)
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Disable statusline
vim.opt.laststatus = 0

-- Indentation defaults: 2 spaces (override per-filetype in after/ftplugin/)
vim.opt.expandtab = true   -- use spaces instead of tabs
vim.opt.shiftwidth = 2     -- spaces per indent level (>> / << / autoindent)
vim.opt.tabstop = 2        -- how wide a tab character displays
vim.opt.softtabstop = 2    -- how many columns Tab inserts in insert mode
