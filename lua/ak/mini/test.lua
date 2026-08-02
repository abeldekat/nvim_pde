---@diagnostic disable: undefined-global
-- Copied and modified from nvim echasnovski, 21_functions.lua.
require('mini.test').setup()

local sync_cursor = function()
  -- Don't use `vim.api.nvim_win_get_cursor()` because of multibyte characters
  local line, col = vim.fn.winline(), vim.fn.wincol()
  local cur_win_id = vim.api.nvim_get_current_win()
  -- Don't use `vim.api.nvim_win_set_cursor()`: it doesn't redraw cursorcolumn
  vim.cmd(string.format('windo call setcursorcharpos(%d, %d)', line, col))
  vim.api.nvim_set_current_win(cur_win_id)
end

local files, dir_path, file_id

local delete_current = function()
  local path = dir_path .. '/' .. files[file_id]
  vim.fn.delete(path)
  vim.notify('Deleted file ' .. vim.inspect(path))
end

local show = function(buf_text, buf_attr)
  local path = dir_path .. '/' .. files[file_id]

  local lines = vim.fn.readfile(path)
  local n = 0.5 * (#lines - 3)

  local text_lines = { path, 'Text' }
  vim.list_extend(text_lines, vim.list_slice(lines, 1, n + 1))
  vim.api.nvim_buf_set_lines(buf_text, 0, -1, true, text_lines)

  local attr_lines = { path, 'Attr' }
  vim.list_extend(attr_lines, vim.list_slice(lines, n + 3, 2 * n + 3))
  vim.api.nvim_buf_set_lines(buf_attr, 0, -1, true, attr_lines)

  pcall(function() MiniTrailspace.unhighlight() end)
end
local show_next = function(buf_text, buf_attr)
  file_id = math.fmod(file_id, #files) + 1
  show(buf_text, buf_attr)
end
local show_prev = function(buf_text, buf_attr)
  file_id = math.fmod(file_id + #files - 2, #files) + 1
  show(buf_text, buf_attr)
end

local setup_windows = function()
  local function buf_win()
    local buf = vim.api.nvim_get_current_buf()
    local win = vim.api.nvim_get_current_win()
    vim.cmd('setlocal bufhidden=wipe nobuflisted')
    vim.api.nvim_create_autocmd('CursorMoved', { buf = buf, callback = sync_cursor })
    return buf, win
  end

  -- -- Set up tab page
  vim.cmd('tabnew')
  local buf_text, win_text = buf_win()
  vim.cmd('belowright wincmd v | wincmd = | enew')
  local buf_attr, win_attr = buf_win()
  vim.api.nvim_set_current_win(win_text)

  -- stylua: ignore start
  local win_options = {
    colorcolumn = '', cursorline = true, cursorcolumn = true, fillchars = 'eob: ',
    foldcolumn = '0', foldlevel = 999,   number = false,      relativenumber = false,
    spell = false,    signcolumn = 'no', wrap = false,
  }
  -- stylua: ignore end
  for name, value in pairs(win_options) do
    vim.api.nvim_set_option_value(name, value, { win = win_text })
    vim.api.nvim_set_option_value(name, value, { win = win_attr })
  end

  -- Set up behavior
  for _, buf_id in ipairs({ buf_text, buf_attr }) do
    vim.keymap.set('n', 'q', ':tabclose!<CR>', { buf = buf_id })
    vim.keymap.set('n', '<C-d>', delete_current, { buf = buf_id })
    vim.keymap.set('n', '<C-n>', function() show_next(buf_text, buf_attr) end, { buf = buf_id })
    vim.keymap.set('n', '<C-p>', function() show_prev(buf_text, buf_attr) end, { buf = buf_id })
  end
  return buf_text, buf_attr
end

local browse = function(path_to_screenshots)
  path_to_screenshots = path_to_screenshots or 'tests/screenshots'
  dir_path = path_to_screenshots
  files = vim.fn.readdir(dir_path)

  local read_file = function(x) return vim.fn.readfile(dir_path .. '/' .. x) end
  vim.ui.select(files, { prompt = 'Choose screenshot', preview_item = read_file }, function(_, idx)
    if idx == nil then return end
    file_id = idx
    show(setup_windows())
  end)
end

Config.minitest_screenshots = { browse = browse }
