local err = require("mocha.core.lib.err")
local M = {}

local function validate_command(name, command, opts)
	vim.validate({
		name = { name, "string" },
		command = { command, { "string", "function" } },

		-- nullable
		opts = { opts, { "table" }, true },
	})
end

---Create a user command
local function cmd(name, command, opts)
	local ok, errmsg = pcall(validate_command, name, command, opts)

	if not ok then
		err(errmsg)

		return
	end

	opts = opts or {}

	ok, errmsg = pcall(vim.api.nvim_create_user_command, name, command, opts)

	if not ok then
		err(errmsg)
	end
end

M.command = cmd

return M.command
