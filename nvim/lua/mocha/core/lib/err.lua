---Notify user of any error via vim.notify(), see :help vim.notify
return function(errmsg)
	vim.notify(errmsg, vim.log.levels.ERROR)
end
