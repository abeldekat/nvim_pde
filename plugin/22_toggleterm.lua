---@diagnostic disable: undefined-global
-- A very simple toggle terminal
-- Reuses a single buffer
-- Splits horizontally or vertically
-- Intended as a dropin replacement for MiniMax <leader>tt and <leader>tT

local state = { toggle = { win = -1, buf = -1 } }

local create = function(opts)
  opts = opts or {}

  -- Create unlisted scratch buffer
  if not vim.api.nvim_buf_is_valid(opts.buf) then opts.buf = vim.api.nvim_create_buf(false, true) end

  -- Split
  vim.cmd((opts.direction and opts.direction .. ' ' or '') .. 'sbuffer ' .. opts.buf)
  vim.cmd.startinsert()

  return { win = vim.api.nvim_get_current_win(), buf = opts.buf }
end

local toggle = function(direction)
  local window_cannot_be_hidden = vim.fn.winnr('$') == 1
  if window_cannot_be_hidden then
    -- Force toggle "on" by invalidating state.toggle.win if it is current
    -- This can happen with "CTRL-W_o" from inside the toggle window
    if vim.api.nvim_get_current_win() == state.toggle.win then state.toggle.win = -1 end

    -- Force alternative edit when state.toggle.buf is current
    -- This can happen if the user manually selected that buffer(via picker for example)
    if vim.api.nvim_get_current_buf() == state.toggle.buf then
      local ok, _ = pcall(vim.cmd.edit, '#')
      if not ok then
        ok, _ = pcall(MiniStarter.open)
      end
      if not ok then vim.cmd('ene') end
    end
  end

  if vim.api.nvim_win_is_valid(state.toggle.win) then
    vim.api.nvim_win_hide(state.toggle.win) -- closes window and hides buf
  else
    state.toggle = create({ buf = state.toggle.buf, direction = direction })
    -- Takes into account that terminal can be killed with ctrl-d
    if vim.bo[state.toggle.buf].buftype ~= 'terminal' then vim.cmd.terminal() end
  end
end

Config.toggleterm_horizontal = toggle
Config.toggleterm_vertical = function() toggle('vertical') end
