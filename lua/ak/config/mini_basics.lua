-- The module has "\" mappings for toggling options like vim-unimpaired,
--
-- TODO: Mappings: Reselect latest changed, put, or yanked text: gV
--
-- Mappings: go and gO: add empty line before or after:
-- gO:
-- gO			Show a filetype-specific, navigable "outline" of the
-- 			current buffer. For example, in a |help| buffer this
-- 			shows the table of contents.
-- go:
-- :[range]go[to] [count]					*:go* *:goto* *go*
-- [count]go		Go to [count] byte in the buffer.

local basics = require("mini.basics")
local config = {

  options = { -- not using options in favor of own options...
    -- Basic options ('number', 'ignorecase', and many more)
    basic = false, -- true. Also optional: win_borders, extra_ui
  },

  mappings = {
    -- Basic mappings (better 'jk', save with Ctrl+S, ...)
    -- copy/paste with system clipboard! gy gp
    basic = true, -- especially: go and gO
    -- Prefix for mappings that toggle common options ('wrap', 'spell', ...).
    option_toggle_prefix = "", -- [[\]],  disable... See keymaps leader u
    -- Window navigation with <C-hjkl>, resize with <C-arrow>
    windows = true,
    -- Move cursor in Insert, Command, and Terminal mode with <M-hjkl>
    move_with_alt = true,
  },

  -- Autocommands. Set to `false` to disable
  autocommands = {
    -- Highlight on yank: See own options
    -- Start terminal with insert: Using toggleterm mostly
    basic = false, -- true -- Also optional: relnum_in_visual_mode
  },

  -- Whether to disable showing non-error feedback
  silent = false,
}

basics.setup(config)

-- vim.keymap.del for mappings you don't want...
--
-- Mappings.basic:
-- Search inside visually highlighted text. Use `silent = false` for it to
-- make effect immediately.
vim.keymap.del("x", "g/")
--
-- Mappings.basic:
-- Alternative way to save and exit in Normal mode.
-- Adding `redraw` helps with `cmdheight=0` if buffer is not modified
vim.keymap.del({ "n", "x", "i" }, "<C-S>")
--
-- Mappings.windows:
-- ctrl-hjkl will be overridden in ak.config.editor.mini_visits
