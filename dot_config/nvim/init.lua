-- Leader must be set before plugins load so <leader> mappings bind correctly.
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

require("config.options")
require("config.keymaps")
require("config.commands")
require("config.lsp")

-- Walk lua/plugins/ and load each spec.
local specs = {}
local setups = {}
for name, _ in vim.fs.dir(vim.fn.stdpath("config") .. "/lua/plugins") do
  if name:match("%.lua$") then
    local mod = require("plugins." .. name:gsub("%.lua$", ""))
    table.insert(specs, { src = mod.src, name = mod.name, version = mod.version, build = mod.build })
    if type(mod.setup) == "function" then
      table.insert(setups, mod.setup)
    end
  end
end

vim.pack.add(specs, { load = true })

for _, setup in ipairs(setups) do
  setup()
end
