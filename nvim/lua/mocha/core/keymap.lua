local err = require('mocha.core.lib.err')
local DEFAULT_OPTS = { noremap = true }
local M = {}

---Validate user opts
local function validate(input, exec)
  vim.validate({
    input = { input, 'string' },
    exec = { exec, { 'string', 'function' } },
  })
end

---Merge default opts from user provided opts
local function merge_opts(opts)
  if opts and type(opts) == 'table' then
    opts = vim.tbl_extend('force', DEFAULT_OPTS, opts)
  else
    opts = DEFAULT_OPTS
  end

  return opts
end

---Map input to exec with provided mode and opts
local function mapper(mode, input, exec, opts)
  local ok, errmsg = pcall(validate, input, exec)

  if not ok then
    err(errmsg)

    return
  end

  opts = merge_opts(opts)

  if opts.bufnr then
    local bufnr = opts.bufnr
    opts.bufnr = nil

    ok, errmsg = pcall(vim.keymap.set, mode, input, exec, vim.tbl_extend('force', { buffer = bufnr }, opts))

    if not ok then
      err(errmsg)
    end
  else
    ok, errmsg = pcall(vim.keymap.set, mode, input, exec, opts)

    if not ok then
      err(errmsg)
    end
  end
end

---Create a normal, visual and operator-pending mode keymap, see :help mapmode-nvo
function M.map(input, exec, opts)
  mapper('', input, exec, opts)
end

---Create a normal mode keymap, see :help mapmode-n
function M.nmap(input, exec, opts)
  mapper('n', input, exec, opts)
end

---Create an insert mode keymap, see :help mapmode-i
function M.imap(input, exec, opts)
  mapper('i', input, exec, opts)
end

---Create a visual mode keymap, see :help mapmode-v
function M.vmap(input, exec, opts)
  mapper('v', input, exec, opts)
end

---Create a terminal mode keymap, see :help mapmode-t
function M.tmap(input, exec, opts)
  mapper('t', input, exec, opts)
end

---Create a command line mode keymap, see :help mapmode-c
function M.cmap(input, exec, opts)
  mapper('c', input, exec, opts)
end

---Create a visual and select mode keymap, see :help mapmode-x
function M.xmap(input, exec, opts)
  mapper('x', input, exec, opts)
end

---Create an operator-pending mode keymap, see :help mapmode-o
function M.omap(input, exec, opts)
  mapper('o', input, exec, opts)
end

---Create a select mode keymap, see :help mapmode-s
function M.smap(input, exec, opts)
  mapper('s', input, exec, opts)
end

return M
