vim.api.nvim_create_user_command("Update", function(opts)
  local names = #opts.fargs > 0 and opts.fargs or nil
  vim.pack.update(names)
end, {
  nargs = "*",
  desc = "Update plugins (optionally specify names)",
})

vim.api.nvim_create_user_command("Clean", function()
  local unused = vim.iter(vim.pack.get())
    :filter(function(x) return not x.active end)
    :map(function(x) return x.spec.name end)
    :totable()
  if #unused == 0 then
    vim.notify("Nothing to clean.", vim.log.levels.INFO)
    return
  end
  vim.pack.del(unused)
end, {
  desc = "Remove plugins no longer in use",
})
