local M = {}

---Set the colorscheme of vim
local function set_colorscheme(theme)
  -- Before colorscheme is set
  if theme.on_before then
    theme.on_before()
  end

  vim.opt.number = true
  vim.opt.termguicolors = true
  vim.api.nvim_command(string.format('colorscheme %s', theme.name))

  if vim.g.colors_name ~= theme.name then
    vim.g.colors_name = theme.name
  end

  -- After colorshceme is set
  if theme.on_after then
    theme.on_after()
  end
end

---Colorscheme setup for transparency and theme
function M.setup(cfg)
  local theme = cfg.theme
  set_colorscheme(theme)
end

return M
