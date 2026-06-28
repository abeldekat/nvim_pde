---@diagnostic disable: undefined-global
local use_as_default_explorer, show_dotfiles, show_preview = true, true, true
local layout_current, layout_next = 'C', { L = 'C', C = 'R', R = 'L' }
local is_full_screen, full_screen_max_number = false, 3
local center_vert = { enable = true, height_focus = 32, height = 30, same_row = true, threshold = 6 }

-- Left and right border to take into account. Col position vs inner width
local x_margin = 2

-- Start copied from mini.files
-- Skipped the override for windows OS as I don't use windows
local fs_normalize_path = function(path) return (path:gsub('/+', '/'):gsub('(.)/$', '%1')) end
-- Centering: change first visible title when expected first window is hidden
local fit_to_width = function(text, width)
  local t_width = vim.fn.strchars(text)
  return t_width <= width and text or ('…' .. vim.fn.strcharpart(text, t_width - width + 1, width - 1))
end
local sanitize_string = function(x) return ((x or ''):gsub('\n', '<NL>'):gsub('%z', '')) end
local fs_shorten_path = function(path)
  -- Replace home directory with '~'
  path = fs_normalize_path(path)
  local home_dir = fs_normalize_path(vim.loop.os_homedir() or '~')
  return (path:gsub('^' .. vim.pesc(home_dir), '~'))
end
-- Full screen: calculate max height
local window_get_max_height = function()
  local has_tabline = vim.o.showtabline == 2 or (vim.o.showtabline == 1 and #vim.api.nvim_list_tabpages() > 1)
  local has_statusline = vim.o.laststatus > 0
  -- Remove 2 from maximum height to account for top and bottom borders
  return vim.o.lines - vim.o.cmdheight - (has_tabline and 1 or 0) - (has_statusline and 1 or 0) - 2
end
-- End copied from mini.files

local get_win_data = function(windows, idx)
  local win_id = windows[idx].win_id
  local config = vim.api.nvim_win_get_config(win_id)
  return win_id, config, config.width + x_margin
end

local center_update_first_visible_title = function(windows, idx)
  local win = windows[idx]
  local config = vim.api.nvim_win_get_config(win.win_id)
  if not type(config.title) == string then return end

  -- Copied from mini.files, see H.explorer_refresh_depth_window
  config.title = ' ' .. sanitize_string(fs_shorten_path(win.path)) .. ' '
  config.title = fit_to_width(config.title, config.width)
  vim.api.nvim_win_set_config(win.win_id, config)
end

local center_set_config = function(config, win_id, show, is_focused, vert_enable)
  if vert_enable then
    local v = center_vert
    config.height = is_focused and v.height_focus or v.height
    config.row = math.floor(0.5 * (vim.o.lines - (v.same_row and v.height or config.height)))
  end
  config.height = not show and 1 or config.height

  local line_count = vim.api.nvim_buf_line_count(vim.api.nvim_win_get_buf(win_id))
  config.footer = { { line_count > config.height and ' · ' or '', 'MiniFilesTitle' } }
  config.footer_pos = 'right'
  vim.api.nvim_win_set_config(win_id, config)
end

local center = function(windows, idx_focused)
  local is_vert = center_vert.enable and (vim.o.lines - center_vert.height_focus >= center_vert.threshold)
  local _, _, width_focused = get_win_data(windows, idx_focused)
  if vim.o.columns <= width_focused then return end

  local col_focused = math.floor((vim.o.columns - width_focused) * 0.5)
  -- From focused to left edge
  local hidden = {}
  local col = col_focused + width_focused
  for i = idx_focused, 1, -1 do
    local win_id, config, width = get_win_data(windows, i)
    local show = i == idx_focused or col >= width

    config.col = show and col - width or col_focused
    center_set_config(config, win_id, show, i == idx_focused, is_vert)
    if not show then table.insert(hidden, i) end
    col = show and config.col or 0
  end
  if #hidden > 0 then center_update_first_visible_title(windows, hidden[1] + 1) end

  -- From focused + 1 to right edge
  col = col_focused + width_focused
  for i = idx_focused + 1, #windows do
    local win_id, config, width = get_win_data(windows, i)
    local show = (vim.o.columns - col) >= width

    config.col = show and col or col_focused
    center_set_config(config, win_id, show, false, is_vert)
    col = show and config.col + width or vim.o.columns
  end
end

local right = function(windows, _)
  -- In the default layout, the first window is aligned to the left edge of the editor
  -- Here, the last window is aligned to the right edge of the editor
  local config_last_window = vim.api.nvim_win_get_config(windows[#windows].win_id)
  local offset = (vim.o.columns - config_last_window.col) - config_last_window.width - x_margin
  for _, win in ipairs(windows) do
    local win_id = win.win_id
    local config = vim.api.nvim_win_get_config(win_id)
    config.col = offset + config.col
    config.footer = config.footer and '' or config.footer
    vim.api.nvim_win_set_config(win_id, config)
  end
end

local full_screen = function(windows, _)
  local nr_of_windows = #windows
  -- All windows have max_height
  local height = window_get_max_height()
  -- All windows have (almost) the same width
  local col_distance = math.floor(vim.o.columns / nr_of_windows)

  local col = 0
  for i = 1, nr_of_windows do
    local win_id, config, _ = get_win_data(windows, i)
    -- Set the col to the new position
    col = (i == 1 and config.col) or (col + col_distance)

    config.col, config.height = col, height
    -- Set the width, and ensure there is no gap after last window
    config.width = (i == nr_of_windows and (vim.o.columns - col) or col_distance) - x_margin
    config.footer = config.footer and '' or config.footer
    vim.api.nvim_win_set_config(win_id, config)
  end
end

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

local full_screen_reset = function() is_full_screen = false end
local toggle_full_screen = function()
  is_full_screen = not is_full_screen
  local max_number = MiniFiles.config.windows.max_number
  max_number = is_full_screen and full_screen_max_number or max_number
  MiniFiles.refresh({ windows = { max_number = max_number } })
end
local full_screen_vim_enter = function(args)
  if not use_as_default_explorer then return end
  if vim.fn.isdirectory(args.file) ~= 1 then return end
  vim.schedule(toggle_full_screen)
end

local make_label_directory = function(call) -- MiniVisits with MiniFiles
  return function()
    local state = MiniFiles.get_explorer_state()
    MiniVisits[call](Config.visits_label, state.branch[state.depth_focus])
  end
end

local add_relative_linenumbers_to_active_window = function(args)
  local win_id = args.data.win_id
  if not (win_id and win_id == vim.api.nvim_get_current_win()) then return end

  vim.wo[win_id].relativenumber = true
  local opts = { once = true, callback = function() vim.wo[win_id].relativenumber = false end }
  vim.api.nvim_create_autocmd('WinLeave', opts)
end

local ensure_layout = function(args) -- https://github.com/nvim-mini/mini.nvim/discussions/2448
  -- Built-in layout, return early
  if layout_current == 'L' and not is_full_screen then return end

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
  if is_full_screen then return full_screen(state.windows, idx_focused) end

  -- Apply center or right in all other cases
  local layout_fn = layout_current == 'C' and center or right
  layout_fn(state.windows, idx_focused)
end

local traverse_layout = function()
  layout_current = layout_next[layout_current]
  MiniFiles.refresh()
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
  nmap('gf', toggle_full_screen, 'Toggle full screen')
  nmap('gp', toggle_preview, 'Toggle preview')
  nmap('gX', ui_open, 'OS open')
  nmap('gy', yank_path, 'Yank path')

  -- Instead of horizontal split, use <C-s> to traverse layout
  nmap('<C-s>', traverse_layout, 'Traverse layout')
  nmap_split(b, '<C-v>', 'belowright vertical')
  nmap_split(b, '<C-t>', 'tab')

  -- Split keyboard with miryoku layout and vim layer, go_in and go_out:
  vim.keymap.set('n', '<Right>', 'l', { buffer = b, remap = true })
  vim.keymap.set('n', '<Left>', 'h', { buffer = b, remap = true })
end

local config = {
  content = { filter = filter_show },
  mappings = { go_in = 'L', go_in_plus = 'l' },
  options = { use_as_default_explorer = use_as_default_explorer },
  windows = { preview = show_preview },
}
require('mini.files').setup(config)

Config.new_autocmd('User', 'MiniFilesExplorerOpen', add_marks, 'Add bookmarks')
Config.new_autocmd('User', 'MiniFilesExplorerClose', full_screen_reset, 'Reset full screen')
Config.new_autocmd('VimEnter', '*', full_screen_vim_enter, 'Full screen on vim <dir>')
Config.new_autocmd('User', 'MiniFilesBufferCreate', add_keymaps, 'Add extra keys')
local on_window_update = function(args)
  add_relative_linenumbers_to_active_window(args)
  ensure_layout(args)
end
Config.new_autocmd('User', 'MiniFilesWindowUpdate', on_window_update, 'Layout and linenumbers')
