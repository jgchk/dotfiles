local M = {
  plugins = {
    { 'nvim-telescope/telescope.nvim' },
    { 'nvim-telescope/telescope-file-browser.nvim' },
  },
}

function M.after()
  local augroup = require('mocha.core.event').augroup
  local nmap = require('mocha.core.keymap').nmap
  local telescope = require('telescope')
  local telescope_builtin = require('telescope.builtin')
  local actions = require('telescope.actions')

  telescope.setup({
    defaults = {
      layout_config = { prompt_position = 'top' },
      layout_strategy = 'horizontal',
      sorting_strategy = 'ascending',
      use_less = false,
      mappings = {
        i = {
          ['<esc>'] = actions.close,
        },
      },
    },
  })

  -- Normal file finder
  local function find_files()
    telescope_builtin.find_files({
      find_command = { 'rg', '--files', '--iglob', '!.git', '--hidden' },
      previewer = false,
    })
  end

  -- Code finder
  local function live_grep()
    telescope_builtin.live_grep({ only_sort_text = true })
  end

  -- Config file finder
  local function find_config_files()
    local configdir = vim.fn.stdpath('config')

    telescope_builtin.find_files({
      find_command = { 'rg', '--files', '--iglob', '!.git', '--hidden', configdir },
      previewer = false,
    })
  end

  nmap('<Leader>vf', find_config_files)

  require('which-key').register({
    ['<leader>f'] = {
      name = 'Find',
      f = { find_files, 'Find Files' },
      g = { live_grep, 'Find Grep' },
      c = {
        function()
          telescope_builtin.git_status()
        end,
        'Find by Changed Lines',
      },
      s = {
        function()
          telescope.extensions.file_browser.file_browser({ path = vim.fn.expand('%:p:h') })
        end,
        'Find in File System',
      },
      b = { '<cmd>Telescope buffers<cr>', 'Find Buffer' },
    },
    ['<leader>cb'] = {
      function()
        telescope_builtin.git_branches()
      end,
      'Change Branches',
    },
  })

  augroup('telescope_user_events', {
    {
      event = 'ColorScheme',
      exec = 'highlight! TelescopeBorder guifg=#aaaaaa',
    },
  })
end

return M
