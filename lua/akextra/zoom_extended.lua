---@diagnostic disable: undefined-global
-- From MiniMisc.zoom:
--
--- Zoom in and out of a buffer, making it full screen in a floating window
--- This function is useful when working with multiple windows but temporarily
--- needing to zoom into one to see more of the code from that buffer. Call it
--- again (without arguments) to zoom out.
--
-- Given the above, zoom's main use case is viewing.
-- However, I often end up navigating and editing, especially on my laptop,
-- with a terminal in a vertical split.
-- I then want to use it as a fast alternative to manually manipulating
-- the window size, keeping the original layout.

-- This 'extra' adds the following:
-- - On 'zoom', ensure that the background color stays the same
-- - On 'zoom', ensure that jump2d only takes the floating window into account
-- - On 'unzoom', set the cursor to the last cursor position in floating window
--
-- Requirements: MiniMisc active
--[[

  -- Example usage
  require('mini.misc').setup()
  require('<this_file').setup()
  vim.keymap.set('n', '<leader>oz', 'lua ZoomExtended.zoom()<CR>', { desc = 'Zoom toggle' })

--]]

local hi = function(name, data) vim.api.nvim_set_hl(0, name, data) end
local hi_get = function(name) return vim.api.nvim_get_hl(0, { name = name }) end

local zoom = function()
  local hl_normal, hl_normal_float = hi_get('Normal'), hi_get('NormalFloat')
  local win_id_before = vim.api.nvim_get_current_win()
  local is_zoomed = MiniMisc.zoom()
  if not is_zoomed then return end

  -- Ensure color stays the same
  hi('NormalFloat', hl_normal)
  -- Add jump2d local override if not already present
  if vim.b.minijump2d_config == nil then
    -- Jump2d should not include the underlying window, which holds the same buffer
    vim.b.minijump2d_config = { allowed_windows = { current = true, not_current = false } }
  end

  -- Add calback to restore when the full screen window is closed
  local win_id_full_screen = vim.api.nvim_get_current_win()
  local on_close = function()
    hi('NormalFloat', hl_normal_float)
    vim.b.minijump2d_config = nil

    -- Use the new cursor position and center
    vim.api.nvim_win_set_cursor(win_id_before, vim.api.nvim_win_get_cursor(win_id_full_screen))
    vim.schedule(function() vim.cmd('normal! zz') end)
  end
  local opts = { once = true, pattern = { '' .. win_id_full_screen }, callback = on_close }
  vim.api.nvim_create_autocmd('WinClosed', opts)
end

local ZoomExtended = {}
ZoomExtended.setup = function() _G.ZoomExtended = ZoomExtended end
ZoomExtended.zoom = zoom
return ZoomExtended
