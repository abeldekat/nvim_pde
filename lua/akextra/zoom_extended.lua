---@diagnostic disable: undefined-global
-- From MiniMisc.zoom:
--- Zoom in and out of a buffer, making it full screen in a floating window
--- This function is useful when working with multiple windows but temporarily
--- needing to zoom into one to see more of the code from that buffer. Call it
--- again (without arguments) to zoom out.

-- Given the above, zoom's main use case is viewing.
-- However, I often also navigate and edit, especially on my laptop,
-- with a terminal in a vertical split.

-- This 'extra' adds the following:
-- - On 'zoom', ensure that the background color stays the same
-- - On 'zoom', ensure that jump2d only takes the floating window into account
-- - On 'unzoom', set the cursor to the last cursor position in floating window

-- Requirements: MiniMisc active
-- Example usage:
--[[
  require('mini.misc').setup()
  require('<this_file').setup()
  vim.keymap.set('n', '<leader>oz', 'lua ZoomExtended.zoom()<CR>', { desc = 'Zoom toggle' })
--]]

local hi = function(name, data) vim.api.nvim_set_hl(0, name, data) end
local hi_get = function(name) return vim.api.nvim_get_hl(0, { name = name }) end

local zoom = function()
  local win_id = vim.api.nvim_get_current_win()
  if not MiniMisc.zoom() then return end

  -- Ensure color stays the same
  local hl_normal_float_orig = hi_get('NormalFloat')
  hi('NormalFloat', hi_get('Normal'))
  -- Jump2d should not include the underlying window, which holds the same buffer
  vim.b.minijump2d_config = { allowed_windows = { current = true, not_current = false } }

  -- Restore when the zoomed window is closed
  local win_id_zoom = vim.api.nvim_get_current_win()
  local on_close = function()
    hi('NormalFloat', hl_normal_float_orig)
    vim.b.minijump2d_config = nil
    -- Back in original window, use zoomed cursor position and center
    vim.api.nvim_win_set_cursor(win_id, vim.api.nvim_win_get_cursor(win_id_zoom))
    vim.schedule(function() vim.cmd('normal! zz') end)
  end
  vim.api.nvim_create_autocmd('WinClosed', { once = true, pattern = { '' .. win_id_zoom }, callback = on_close })
end

local ZoomExtended = {}
ZoomExtended.setup = function() _G.ZoomExtended = ZoomExtended end
ZoomExtended.zoom = zoom
return ZoomExtended
