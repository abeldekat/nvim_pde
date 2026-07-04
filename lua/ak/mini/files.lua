---@diagnostic disable: undefined-global
local au = Config.new_autocmd
local show_dotfiles, show_preview = true, true

local nmap_split = function(buf_id, lhs, direction)
  local rhs = function()
    -- Make new window and set it as target
    local cur_target = MiniFiles.get_explorer_state().target_window
    local new_target = vim.api.nvim_win_call(cur_target, function()
      vim.cmd(direction .. ' split')
      return vim.api.nvim_get_current_win()
    end)
    MiniFiles.set_target_window(new_target)
    MiniFiles.go_in({ close_on_file = true })
  end
  local desc = 'Split ' .. direction
  vim.keymap.set('n', lhs, rhs, { buffer = buf_id, desc = desc })
end

local set_cwd = function() -- set focused directory as current working directory
  local path = (MiniFiles.get_fs_entry() or {}).path
  if path == nil then return vim.notify('Cursor is not on valid entry') end
  vim.fn.chdir(vim.fs.dirname(path))
end

local yank_path = function() -- yank in register full path of entry under cursor
  local path = (MiniFiles.get_fs_entry() or {}).path
  if path == nil then return vim.notify('Cursor is not on valid entry') end
  vim.fn.setreg(vim.v.register, path)
end

-- Open path with system default handler (useful for non-text files)
local ui_open = function() vim.ui.open(MiniFiles.get_fs_entry().path) end

local filter_show = function(_) return true end
local filter_hide = function(fs_entry) return not vim.startswith(fs_entry.name, '.') end
local toggle_dotfiles = function()
  show_dotfiles = not show_dotfiles
  local new_filter = show_dotfiles and filter_show or filter_hide
  MiniFiles.refresh({ content = { filter = new_filter } })
end

local toggle_preview = function()
  show_preview = not show_preview
  MiniFiles.refresh({ windows = { preview = show_preview } })
end

local make_label_directory = function(call) -- MiniVisits with MiniFiles
  return function()
    local state = MiniFiles.get_explorer_state()
    MiniVisits[call](Config.visits_label, state.branch[state.depth_focus])
  end
end

local pick_files = function()
  MiniPick.builtin.files(nil, { source = { cwd = vim.fs.dirname(MiniFiles.get_fs_entry().path) } })
end

local add_linenumbers = function(args)
  local win_id = args.data.win_id
  if not (win_id and win_id == vim.api.nvim_get_current_win()) then return end

  vim.wo[win_id].relativenumber = true
  local opts = { once = true, callback = function() vim.wo[win_id].relativenumber = false end }
  vim.api.nvim_create_autocmd('WinLeave', opts)
end

local add_marks = function()
  MiniFiles.set_bookmark('c', vim.fn.stdpath('config') .. '', { desc = 'Config' })
  MiniFiles.set_bookmark('m', vim.fn.stdpath('data') .. '/site/pack/core/opt/mini.nvim', { desc = 'Mini' })
  MiniFiles.set_bookmark('p', vim.fn.stdpath('data') .. '/site/pack/core/opt', { desc = 'Plugins' })
  MiniFiles.set_bookmark('w', vim.fn.getcwd, { desc = 'Working directory' })
end

local add_keymaps = function(args)
  local b = args.data.buf_id
  local nmap = function(lhs, rhs, desc) vim.keymap.set('n', lhs, rhs, { buffer = b, desc = desc }) end

  nmap('g.', toggle_dotfiles, 'Toggle dotfiles')
  -- When MiniMisc.setup_auto_root() is active, set_cwd is not that useful
  nmap('g~', set_cwd, 'Set cwd')
  -- Unlike netrw, MiniVisits cannot be used directly in MiniFiles
  nmap('gd', make_label_directory('add_label'), 'Visits add label')
  nmap('gD', make_label_directory('remove_label'), 'Visits remove label')
  if FilesLayout then nmap('gf', FilesLayout.toggle_full_screen, 'Toggle full screen') end
  if MiniPick then nmap('gp', pick_files, 'Pick files') end
  nmap('gP', toggle_preview, 'Toggle preview')
  nmap('gX', ui_open, 'OS open')
  nmap('gy', yank_path, 'Yank path')

  -- Instead of horizontal split, use <C-s> to traverse layout
  if FilesLayout then nmap('<C-s>', FilesLayout.traverse, 'Traverse layout') end
  nmap_split(b, '<C-v>', 'belowright vertical')
  nmap_split(b, '<C-t>', 'tab')

  -- Split keyboard with miryoku layout and vim layer, go_in and go_out:
  vim.keymap.set('n', '<Right>', 'l', { buffer = b, remap = true })
  vim.keymap.set('n', '<Left>', 'h', { buffer = b, remap = true })
end

local config = {
  content = { filter = filter_show },
  mappings = { go_in = 'L', go_in_plus = 'l' },
  -- options = { use_as_default_explorer = false },
  windows = { preview = show_preview },
}
require('mini.files').setup(config)
au('User', 'MiniFilesExplorerOpen', add_marks, 'Add bookmarks')
au('User', 'MiniFilesWindowUpdate', add_linenumbers, 'Add linenumbers')

require('akextra.files_layout').setup()
au('User', 'MiniFilesBufferCreate', add_keymaps, 'Add extra keys')
