---@diagnostic disable: undefined-global
-- A very simple toggle terminal, caching a single terminal buffer.
-- Only splits horizontally or vertically.
-- To be used as a dropin replacement for MiniMax <leader>tt and <leader>tT.
--
-- In Neovim, a window cannot be closed if it is the only window.
-- Thus, that "window" edge case needs to be handled on toggle:
-- -- toggle.win is current(ensure toggle on)
-- -- and/or toggle.buf is current(ensure alternative edit)
--
-- In Neovim, in terminal mode, any terminal can be closed with ctrl-d("exit").
-- Its buffer will be gone and if possible its window will be closed.
-- This also prevents a buffer picker from being cluttered with buffer terminals.
--
-- A new buffer will be added to the cache after closing a toggle with ctrl-d.

local state = { toggle = { win = -1, buf = -1 } }

local create = function(opts)
  opts = opts or {}

  -- Create unlisted scratch buffer if needed. Split and start insert mode
  if not vim.api.nvim_buf_is_valid(opts.buf) then opts.buf = vim.api.nvim_create_buf(false, true) end
  vim.cmd((opts.direction and opts.direction .. ' ' or '') .. 'sbuffer ' .. opts.buf)
  vim.cmd.startinsert()

  return { win = vim.api.nvim_get_current_win(), buf = opts.buf }
end

local edit_alternative = function()
  local ok, _ = pcall(vim.cmd.edit, '#')
  if not ok then
    ok, _ = pcall(MiniStarter.open)
  end
  if not ok then vim.cmd('ene') end
end

local toggle = function(direction)
  -- Ensure "toggle activates" when there is only one window in tab
  if vim.fn.winnr('$') == 1 then
    if vim.api.nvim_get_current_win() == state.toggle.win then state.toggle.win = -1 end
    if vim.api.nvim_get_current_buf() == state.toggle.buf then edit_alternative() end
  end

  -- Toggle
  local win, buf = state.toggle.win, state.toggle.buf
  if vim.api.nvim_win_is_valid(win) and vim.api.nvim_win_get_buf(win) == buf then
    vim.api.nvim_win_hide(win)
  else
    state.toggle = create({ buf = buf, direction = direction })
    if vim.bo[state.toggle.buf].buftype ~= 'terminal' then vim.cmd.terminal() end
  end
end

Config.toggleterm_horizontal = toggle
Config.toggleterm_vertical = function() toggle('vertical') end
