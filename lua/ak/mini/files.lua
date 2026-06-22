---@diagnostic disable: undefined-global
local H = {}

local setup = function()
  local config = {
    content = { filter = H.filter_show },
    mappings = { go_in = 'L', go_in_plus = 'l' },
    windows = { max_number = H.max_windows, preview = H.can_preview() },
  }
  require('mini.files').setup(config)

  Config.new_autocmd('User', 'MiniFilesExplorerOpen', H.add_marks, 'Add bookmarks')
  Config.new_autocmd('User', 'MiniFilesExplorerClose', H.full_screen_reset, 'Reset full screen')
  Config.new_autocmd('VimEnter', '*', H.full_screen_vim_enter, 'Full screen on vim <dir>')
  Config.new_autocmd('User', 'MiniFilesBufferCreate', H.add_keymaps, 'Add extra keys')

  local on_window_update = function(args)
    H.add_relative_linenumbers_to_active_window(args)
    H.ensure_layout(args)
  end
  Config.new_autocmd('User', 'MiniFilesWindowUpdate', on_window_update, 'MiniFilesWindowUpdate')
end

H.show_hidden = true
H.min_windows, H.max_windows = 2, math.huge
H.layout_current, H.layout_next = 'C', { L = 'C', C = 'R', R = 'L' }
H.is_full_screen, H.full_screen_max_number = false, 3
H.center_vert = { enable = true, height_focus = 32, height = 30, align_row = true, threshold = 6 }
-- Left and right border to take into account. Col position vs inner width
H.x_margin = 2

H.add_marks = function()
  MiniFiles.set_bookmark('c', vim.fn.stdpath('config') .. '', { desc = 'Config' })
  MiniFiles.set_bookmark('m', vim.fn.stdpath('data') .. '/site/pack/core/opt/mini.nvim', { desc = 'Mini' })
  MiniFiles.set_bookmark('p', vim.fn.stdpath('data') .. '/site/pack/core/opt', { desc = 'Plugins' })
  MiniFiles.set_bookmark('w', vim.fn.getcwd, { desc = 'Working directory' })
end

H.add_keymaps = function(args)
  local b = args.data.buf_id
  local nmap = function(lhs, rhs, desc) vim.keymap.set('n', lhs, rhs, { buffer = b, desc = desc }) end

  nmap('g.', H.toggle_hidden, 'Toggle hidden')
  -- Set cwd is not that useful when MiniMisc.setup_auto_root() is active
  nmap('g~', H.set_cwd, 'Set cwd')
  -- Unlike netrw, MiniVisits cannot be used directly in MiniFiles
  nmap('gd', H.make_label_directory('add_label'), 'Visits add label')
  nmap('gD', H.make_label_directory('remove_label'), 'Visits remove label')
  nmap('gm', H.toggle_max_windows, 'Toggle max windows')
  nmap('gX', H.ui_open, 'OS open')
  nmap('gy', H.yank_path, 'Yank path')
  nmap('gf', H.full_screen_toggle, 'Toggle full screen')
  -- Instead of horizontal split, use <C-s> to traverse layout
  nmap('<C-s>', H.traverse_layout, 'Traverse layout')

  H.nmap_split(b, '<C-v>', 'belowright vertical')
  H.nmap_split(b, '<C-t>', 'tab')

  -- Split keyboard with miryoku layout and vim layer, go_in and go_out:
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

H.full_screen_toggle = function()
  H.is_full_screen = not H.is_full_screen
  local max_number = MiniFiles.config.windows.max_number
  max_number = H.is_full_screen and H.full_screen_max_number or max_number
  MiniFiles.refresh({ windows = { max_number = max_number } })
end

H.full_screen_reset = function() H.is_full_screen = false end

H.full_screen_vim_enter = function(args)
  if vim.fn.isdirectory(args.file) ~= 1 then return end
  vim.schedule(H.full_screen_toggle)
end

H.traverse_layout = function()
  H.layout_current = H.layout_next[H.layout_current]
  MiniFiles.refresh()
end

H.ensure_layout = function(args)
  -- Built-in layout, return early
  if H.layout_current == 'L' and not H.is_full_screen then return end

  -- If there is no state, return early
  local state = MiniFiles.get_explorer_state()
  if state == nil then return end

  -- If event is not for focused window, return early
  local focused_path = state.branch[state.depth_focus]
  local idx_focused
  for i, win in ipairs(state.windows) do
    if win.path == focused_path and win.win_id == args.data.win_id then idx_focused = i end
  end
  if idx_focused == nil then return end

  -- Make explorer appear full screen
  if H.is_full_screen then return H.full_screen(state.windows, idx_focused) end

  -- Apply center or right in all other cases
  local layout_fn = H.layout_current == 'C' and H.center or H.right
  layout_fn(state.windows, idx_focused)
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
    config.footer = config.footer and '' or config.footer
    vim.api.nvim_win_set_config(win_id, config)
  end
end

-- See https://github.com/nvim-mini/mini.nvim/discussions/2448
H.center = function(windows, idx_focused)
  local is_vert = H.center_vert.enable and (vim.o.lines - H.center_vert.height_focus >= H.center_vert.threshold)
  local _, _, width_focused = H.get_win_data(windows, idx_focused)
  if vim.o.columns <= width_focused then return end

  local col_focused = math.floor((vim.o.columns - width_focused) * 0.5)
  -- From focused to left edge
  local hidden = {}
  local col = col_focused + width_focused
  for i = idx_focused, 1, -1 do
    local win_id, config, width = H.get_win_data(windows, i)
    local show = i == idx_focused or col >= width

    config.col = show and col - width or col_focused
    H.center_set_config(config, win_id, show, i == idx_focused, is_vert)
    if not show then table.insert(hidden, i) end
    col = show and config.col or 0
  end
  if #hidden > 0 then H.center_update_first_visible_title(windows, hidden[1] + 1) end

  -- From focused + 1 to right edge
  col = col_focused + width_focused
  for i = idx_focused + 1, #windows do
    local win_id, config, width = H.get_win_data(windows, i)
    local show = (vim.o.columns - col) >= width

    config.col = show and col or col_focused
    H.center_set_config(config, win_id, show, false, is_vert)
    col = show and config.col + width or vim.o.columns
  end
end

H.center_set_config = function(config, win_id, show, is_focused, vert_enable)
  if vert_enable then
    local v = H.center_vert
    config.height = is_focused and v.height_focus or v.height
    config.row = math.floor(0.5 * (vim.o.lines - (v.align_row and v.height or config.height)))
  end
  config.height = not show and 1 or config.height

  local line_count = vim.api.nvim_buf_line_count(vim.api.nvim_win_get_buf(win_id))
  local footer = ''
  if line_count > config.height then
    footer = string.format(' %d/%d ', vim.api.nvim_win_get_cursor(win_id)[1], line_count)
  end
  config.footer = { { footer, 'MiniFilesTitle' } }
  config.footer_pos = 'right'

  vim.api.nvim_win_set_config(win_id, config)
end

H.center_update_first_visible_title = function(windows, idx)
  local win = windows[idx]
  local config = vim.api.nvim_win_get_config(win.win_id)
  if not type(config.title) == string then return end

  config.title = ' ' .. H.sanitize_string(H.fs_shorten_path(win.path)) .. ' '
  config.title = H.fit_to_width(config.title, config.width)
  vim.api.nvim_win_set_config(win.win_id, config)
end

H.full_screen = function(windows, _)
  local nr_of_windows = #windows
  -- All windows have max_height
  local height = H.window_get_max_height()
  -- All windows have (almost) the same width
  local col_distance = math.floor(vim.o.columns / nr_of_windows)

  local col = 0
  for i = 1, nr_of_windows do
    local win_id, config, _ = H.get_win_data(windows, i)
    -- Set the col to the new position
    col = (i == 1 and config.col) or (col + col_distance)

    config.col, config.height = col, height
    -- Set the width, and ensure there is no gap after last window
    config.width = (i == nr_of_windows and (vim.o.columns - col) or col_distance) - H.x_margin
    config.footer = config.footer and '' or config.footer
    vim.api.nvim_win_set_config(win_id, config)
  end
end

H.get_win_data = function(windows, idx)
  local win_id = windows[idx].win_id
  local config = vim.api.nvim_win_get_config(win_id)
  return win_id, config, config.width + H.x_margin
end

H.filter_show = function(_) return true end
H.filter_hide = function(fs_entry) return not vim.startswith(fs_entry.name, '.') end
H.toggle_hidden = function()
  H.show_hidden = not H.show_hidden
  local new_filter = H.show_hidden and H.filter_show or H.filter_hide
  MiniFiles.refresh({ content = { filter = new_filter } })
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

H.make_label_directory = function(call)
  return function()
    local state = MiniFiles.get_explorer_state()
    MiniVisits[call](Config.visits_label, state.branch[state.depth_focus])
  end
end

H.toggle_max_windows = function()
  H.max_windows = H.max_windows == H.min_windows and math.huge or H.min_windows
  MiniFiles.refresh({ windows = { max_number = H.max_windows, preview = H.can_preview() } })
end

H.can_preview = function() return H.max_windows > 1 end

H.nmap_split = function(buf_id, lhs, direction)
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

-- Centering: Copied from mini.files to change first visible title when expected first window is hidden
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

-- Full screen: Copied from mini.files to calculate max height
H.window_get_max_height = function()
  local has_tabline = vim.o.showtabline == 2 or (vim.o.showtabline == 1 and #vim.api.nvim_list_tabpages() > 1)
  local has_statusline = vim.o.laststatus > 0
  -- Remove 2 from maximum height to account for top and bottom borders
  return vim.o.lines - vim.o.cmdheight - (has_tabline and 1 or 0) - (has_statusline and 1 or 0) - 2
end
-- End copied from mini.files

setup()
