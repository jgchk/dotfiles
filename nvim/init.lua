local core = require("mocha.core")
core.setup({
	config = {
		-- Leader key
		leader = " ",

		-- Colorscheme config
		theme = {
			name = "gruvbox",
		},

		-- Adjust packer config
		plugins = {
			init = {
				compile_path = vim.fn.stdpath("data") .. "/site/plugin/packer_compiled.lua",
			},
		},
	},

	-- Events
	on_before = function()
		local autocmd = require("mocha.core.event").autocmd

		-- Highlight text yank
		autocmd({
			event = "TextYankPost",
			exec = function()
				vim.highlight.on_yank({ higroup = "Search", timeout = 500 })
			end,
		})
	end,

	on_after = function()
		require("mocha.user.keymaps")
		require("mocha.user.options")
		require("mocha.user.abbreviations")

		-- Custom user commands
		require("mocha.user.conceal")
		require("mocha.user.codeshot")
	end,
})
