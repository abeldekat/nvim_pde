---@diagnostic disable: undefined-global
local H = {}

local setup = function()
  local config = {
    content = { filter = H.filter_show },
    mappings = { go_in = 'L', go_in_plus = 'l' }, -- close explorer after opening file with `l`
    -- Default widths: 50 - 25 - 15
    windows = { max_number = H.max_windows, preview = H.can_preview() },
  }
  require('mini.files').setup(config)
  H.create_autocommmands()
end

H.create_autocommmands = function()
  Config.new_autocmd('User', 'MiniFilesExplorerOpen', H.add_marks, 'Add bookmarks')
  Config.new_autocmd('User', 'MiniFilesBufferCreate', H.add_keymaps, 'Add extra keys')

  local on_window_update = function(args)
    H.add_relative_linenumbers_to_active_window(args)
    H.ensure_layout(args)
  end
  Config.new_autocmd('User', 'MiniFilesWindowUpdate', on_window_update, 'MiniFilesWindowUpdate')
end

H.show_dotfiles = true
H.min_windows = 2
H.max_windows = math.huge

H.current_layout = 'C'
H.next_layout = { L = 'C', C = 'R', R = 'L' }

-- Centering:
H.x_margin = 2
-- Default zindex when centered
H.zindex = 99
-- Config to center vertically
H.vert = { enable = true, height_focus = 22, height = 20, threshold = 6 }

H.add_marks = function()
  MiniFiles.set_bookmark('c', vim.fn.stdpath('config') .. '', { desc = 'Config' })
  MiniFiles.set_bookmark('m', vim.fn.stdpath('data') .. '/site/pack/core/opt/mini.nvim', { desc = 'Mini' })
  MiniFiles.set_bookmark('p', vim.fn.stdpath('data') .. '/site/pack/core/opt', { desc = 'Plugins' })
  MiniFiles.set_bookmark('w', vim.fn.getcwd, { desc = 'Working directory' })
end

H.add_keymaps = function(args)
  local b = args.data.buf_id

  vim.keymap.set('n', 'g.', H.toggle_dotfiles, { buffer = b })
  vim.keymap.set('n', 'g~', H.set_cwd, { buffer = b, desc = 'Set cwd' })
  vim.keymap.set('n', 'gm', H.toggle_max_windows, { buffer = b, desc = 'Toggle max windows' })
  vim.keymap.set('n', 'gX', H.ui_open, { buffer = b, desc = 'OS open' })
  vim.keymap.set('n', 'gy', H.yank_path, { buffer = b, desc = 'Yank path' })

  vim.keymap.set('n', '<C-s>', H.traverse_layout, { buffer = b, desc = 'Traverse layout' })
  -- H.map_split(b, '<C-s>', 'belowright horizontal')
  H.map_split(b, '<C-v>', 'belowright vertical')
  H.map_split(b, '<C-t>', 'tab')

  -- split keyboard with miryoku layout and vim layer, go_in and go_out:
  vim.keymap.set('n', '<Right>', 'l', { buffer = b, remap = true })
  vim.keymap.set('n', '<Left>', 'h', { buffer = b, remap = true })
end

H.add_relative_linenumbers_to_active_window = function(args)
  local win_id = args.data.win_id
  if not (win_id and win_id == vim.api.nvim_get_current_win()) then return end

  vim.wo[win_id].relativenumber = true
  local opts = { once = true, callback = function() vim.wo[win_id].relativenumber = false end }
  vim.api.nvim_create_autocmd('WinLeave', opts)
end

H.traverse_layout = function()
  H.current_layout = H.next_layout[H.current_layout]
  MiniFiles.refresh()
end

H.ensure_layout = function(args)
  -- No extra steps when layout is builtin
  if H.current_layout == 'L' then return end

  -- There is always a state on a MiniFilesWindow event
  local state = MiniFiles.get_explorer_state()
  if state == nil then return end

  -- Return when event is not for focused window
  local focused_path = state.branch[state.depth_focus]
  local idx_focused
  for i, win in ipairs(state.windows) do
    if win.path == focused_path and win.win_id == args.data.win_id then idx_focused = i end
  end
  if idx_focused == nil then return end

  -- Apply layout in one pass
  local layout = H.current_layout == 'C' and H.center or H.right
  layout(state.windows, idx_focused)
end

H.right = function(windows, _)
  -- In the default layout, the first window is aligned to the left edge of the editor
  -- Here, the last window is aligned to the right edge of the editor

  local config_last_window = vim.api.nvim_win_get_config(windows[#windows].win_id)
  local offset = (vim.o.columns - config_last_window.col) - config_last_window.width - H.x_margin
  for _, win in ipairs(windows) do
    local win_id = win.win_id
    local config = vim.api.nvim_win_get_config(win_id)
    config.col = offset + config.col
    vim.api.nvim_win_set_config(win_id, config)
  end
end

-- See https://github.com/nvim-mini/mini.nvim/discussions/2173
H.center = function(windows, idx_focused)
  -- Use the same widths as in MiniFiles, compute_visible_depth_range
  local config = MiniFiles.config
  local width_focus, width_nofocus = config.windows.width_focus + H.x_margin, config.windows.width_nofocus + H.x_margin

  -- No centering needed
  if vim.o.columns <= width_focus then return end

  -- Center focused window
  local col_focus = math.floor((vim.o.columns - width_focus) * 0.5)
  H.center_set_config(windows, idx_focused, col_focus, true, true)

  -- Prepend left part. If a window does not fit, the col stays the last left-most col
  local col_left = col_focus
  local idx_hidden
  for i = idx_focused - 1, 1, -1 do
    local show = col_left >= width_nofocus
    col_left = show and col_left - width_nofocus or col_left
    idx_hidden = not show and idx_hidden == nil and i or idx_hidden

    H.center_set_config(windows, i, col_left, show, false)
  end
  if idx_hidden then H.center_update_first_visible_title(windows, idx_hidden + 1) end

  -- Append right part. If a window does not fit, the col stays the last right-most col
  local width_preview = config.windows.width_preview + H.x_margin
  local col_right = col_focus + width_focus
  for i = idx_focused + 1, #windows do
    local width = (i == idx_focused + 1) and config.windows.preview and width_preview or width_nofocus
    local show = (vim.o.columns - col_right) >= width
    local col = show and col_right or vim.api.nvim_win_get_config(windows[i - 1].win_id).col

    H.center_set_config(windows, i, col, show, false)
    if show then col_right = col_right + width end
  end
end

H.center_set_config = function(windows, idx, col, show, is_focused)
  local win_id = windows[idx].win_id
  local config = vim.api.nvim_win_get_config(win_id)

  config.zindex = H.zindex
  config.col = col

  -- Overlap concerns: If free vertical space < threshold, don't center
  if H.vert.enable and (vim.o.lines - H.vert.height_focus >= H.vert.threshold) then
    config.height = is_focused and H.vert.height_focus or H.vert.height
    config.row = math.floor(0.5 * (vim.o.lines - config.height))
  end

  if not show then
    config.zindex = H.zindex - idx
    config.height = 1
  end

  vim.api.nvim_win_set_config(win_id, config)
end

H.center_update_first_visible_title = function(windows, idx)
  -- Change the title for the first visible window
  local win = windows[idx]
  if not win then return end

  local config = vim.api.nvim_win_get_config(win.win_id)
  if not type(config.title) == string then return end

  config.title = H.fs_shorten_path(win.path)
  config.title = ' ' .. H.sanitize_string(config.title) .. ' '
  config.title = H.fit_to_width(config.title, config.width)
  vim.api.nvim_win_set_config(win.win_id, config)
end

H.filter_show = function(_) return true end
H.filter_hide = function(fs_entry) return not vim.startswith(fs_entry.name, '.') end
H.toggle_dotfiles = function()
  H.show_dotfiles = not H.show_dotfiles
  local new_filter = H.show_dotfiles and H.filter_show or H.filter_hide
  MiniFiles.refresh({ content = { filter = new_filter } })
end

H.map_split = function(buf_id, lhs, direction)
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

H.set_cwd = function() -- set focused directory as current working directory
  local path = (MiniFiles.get_fs_entry() or {}).path
  if path == nil then return vim.notify('Cursor is not on valid entry') end

  vim.fn.chdir(vim.fs.dirname(path))
end

H.yank_path = function() -- yank in register full path of entry under cursor
  local path = (MiniFiles.get_fs_entry() or {}).path
  if path == nil then return vim.notify('Cursor is not on valid entry') end

  vim.fn.setreg(vim.v.register, path)
end

H.ui_open = function() vim.ui.open(MiniFiles.get_fs_entry().path) end

H.toggle_max_windows = function()
  H.max_windows = H.max_windows == H.min_windows and math.huge or H.min_windows
  MiniFiles.refresh({ windows = { max_number = H.max_windows, preview = H.can_preview() } })
end

H.can_preview = function() return H.max_windows > 1 end

-- Copied from mini.files to change first visible title when expected first window is hidden
H.fit_to_width = function(text, width)
  local t_width = vim.fn.strchars(text)
  return t_width <= width and text or ('…' .. vim.fn.strcharpart(text, t_width - width + 1, width - 1))
end
H.sanitize_string = function(x) return ((x or ''):gsub('\n', '<NL>'):gsub('%z', '')) end
H.fs_shorten_path = function(path)
  -- Replace home directory with '~'
  path = H.fs_normalize_path(path)
  local home_dir = H.fs_normalize_path(vim.loop.os_homedir() or '~')
  return (path:gsub('^' .. vim.pesc(home_dir), '~'))
end
-- Skipped the override for windows OS as I don't use windows
H.fs_normalize_path = function(path) return (path:gsub('/+', '/'):gsub('(.)/$', '%1')) end

setup()
