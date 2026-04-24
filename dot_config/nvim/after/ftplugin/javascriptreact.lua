-- Don't auto-continue // comments; keep /* */ block comments.
vim.opt_local.comments:remove("://")
vim.opt_local.comments:append("f://")
