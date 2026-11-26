---@diagnostic disable: undefined-global
-- A simple toggle terminal, caching a single terminal buffer.
-- Only splits horizontally or vertically.
-- To be used as a dropin replacement for MiniMax <leader>tt and <leader>tT.
--
-- In Neovim, in terminal mode, any terminal can be closed with ctrl-d("exit").
-- Its buffer will be gone and if possible its window will be closed.
-- This also prevents a buffer picker from being cluttered with buffer terminals.
--
-- Here, the cached buffer will be replaced when toggle is closed with ctrl-d.

-- Example usage:
--[[
  Save this file as <path_to_config>/plugin/21_toggleterm.lua
  In plugin/20_keymaps.lua, modify <leader>tt and <leader>tT as follows:

  local tmap_leader = function(suffix, rhs, desc)
    vim.keymap.set('t', '<Leader>' .. suffix, rhs, { desc = desc })
  end
  local toggle_vertical = '<Cmd>lua Config.toggleterm_vertical()<CR>'
  local toggle_horizontal = '<Cmd>lua Config.toggleterm_horizontal()<CR>'
  nmap_leader('tt', toggle_vertical,   'ToggleTerminal (vertical)')
  tmap_leader('tt', toggle_vertical,   'ToggleTerminal (vertical)')
  nmap_leader('tT', toggle_horizontal, 'ToggleTerminal (horizontal)')
  tmap_leader('tT', toggle_horizontal, 'ToggleTerminal (horizontal)')
--]]

local state = { toggle = { win = -1, buf = -1 } }

local edit_alternative = function()
  local ok, _ = pcall(vim.cmd.edit, '#')
  if not ok then
    ok, _ = pcall(MiniStarter.open)
  end
  if not ok then vim.cmd('ene') end
end

local is_on = function()
  local t = state.toggle
  return vim.api.nvim_win_is_valid(t.win) and vim.api.nvim_win_get_buf(t.win) == t.buf
end

local toggle_off = function() vim.api.nvim_win_hide(state.toggle.win) end

local toggle_on = function(direction)
  local t = state.toggle

  -- Ensure unlisted scratch buffer
  if not vim.api.nvim_buf_is_valid(t.buf) then t.buf = vim.api.nvim_create_buf(false, true) end
  -- Split
  vim.cmd((direction and direction .. ' ' or '') .. 'sbuffer ' .. t.buf)
  -- Ensure terminal
  if vim.bo[t.buf].buftype ~= 'terminal' then vim.cmd.terminal() end
  -- Ensure insert mode
  vim.cmd.startinsert()

  return { win = vim.api.nvim_get_current_win(), buf = t.buf }
end

local toggle = function(direction)
  local t = state.toggle

  -- First toggle "off" if toggle is "on" in another tabpage
  if is_on() and vim.api.nvim_win_get_tabpage(t.win) ~= vim.api.nvim_get_current_tabpage() then toggle_off() end

  -- Toggle "on"
  if not is_on() then
    state.toggle = toggle_on(direction)
    return
  end

  -- Toggle "off"
  if vim.fn.winnr('$') > 1 then
    toggle_off()
    return
  end

  -- Toggle "off", but don't try to nvim_win_hide a single window
  -- For example, after "CTRL_W-o" from inside toggle window
  edit_alternative()
end

Config.toggleterm_horizontal = toggle
Config.toggleterm_vertical = function() toggle('vertical') end
