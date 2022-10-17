-- Reload all user config lua modules
return function()
	for name, _ in pairs(package.loaded) do
		if name:match("^mocha") then
			package.loaded[name] = nil
		end
	end

	dofile(vim.env.MYVIMRC)
end
