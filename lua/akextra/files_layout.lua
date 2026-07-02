---@diagnostic disable: undefined-global
-- mini.files with layouts: left(l), center(c), right(r). Toggle full-screen.
-- See https://github.com/nvim-mini/mini.nvim/discussions/2448
-- Requirement: MiniFiles active
--[[

  -- Example usage:
  require('mini.files').setup()
  require('<this_file>').setup()
  local gr = vim.api.nvim_create_augroup('custom-config', {})
  vim.api.nvim_create_autocmd('User', {
    group = gr,
    pattern = 'MiniFilesBufferCreate',
    callback = function(args)
      local b = args.data.buf_id
      vim.keymap.set('n', '<C-s>', FilesLayout.traverse, { buffer = b })
      vim.keymap.set('n', 'gf', FilesLayout.toggle_full_screen, { buffer = b })
    end
  })

--]]

-- The layout to start with, and the order of traversal
local layout_current, layout_next = 'L', { L = 'C', C = 'R', R = 'L' }
-- Full screen flag, and max_windows when in full screen
local is_full_screen, full_screen_max_number = false, 3
-- If enabled and the layout is center, also center vertically
local center_vert = {
  enable = true,
  height_focus = 32,
  height = 30,
  -- Ensure that all windows have the same top row
  align_titles = true,
  -- Do not center vertically if remaining vertical space is lower than threshold
  threshold = 6,
}
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
    config.row = math.floor(0.5 * (vim.o.lines - (v.align_titles and v.height or config.height)))
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

local toggle_full_screen = function()
  is_full_screen = not is_full_screen
  local max_number = MiniFiles.config.windows.max_number
  max_number = is_full_screen and full_screen_max_number or max_number
  MiniFiles.refresh({ windows = { max_number = max_number } })
end
local full_screen_reset = function() is_full_screen = false end
local full_screen_vim_enter = function(args)
  if not MiniFiles.config.options.use_as_default_explorer then return end
  if vim.fn.isdirectory(args.file) ~= 1 then return end
  vim.schedule(toggle_full_screen)
end

local ensure_layout = function(args)
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

local FilesLayout = {}
FilesLayout.setup = function()
  _G.FilesLayout = FilesLayout

  local gr = vim.api.nvim_create_augroup('FilesLayout', {})
  local au = function(event, pattern, callback, desc)
    local opts = { group = gr, pattern = pattern, callback = callback, desc = desc }
    vim.api.nvim_create_autocmd(event, opts)
  end

  au('VimEnter', '*', full_screen_vim_enter, 'Full screen on vim <dir>')
  au('User', 'MiniFilesExplorerClose', full_screen_reset, 'Reset full screen')
  au('User', 'MiniFilesWindowUpdate', ensure_layout, 'Ensure layout')
end
FilesLayout.toggle_full_screen = toggle_full_screen
FilesLayout.traverse = function()
  layout_current = layout_next[layout_current]
  MiniFiles.refresh()
end
return FilesLayout
