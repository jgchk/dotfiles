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
