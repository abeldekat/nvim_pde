-- The module has "\" mappings for toggling options like vim-unimpaired,
--
-- Mappings: go and gO: add empty line before or after:
-- gO:
-- gO			Show a filetype-specific, navigable "outline" of the
-- 			current buffer. For example, in a |help| buffer this
-- 			shows the table of contents.
-- go:
-- :[range]go[to] [count]					*:go* *:goto* *go*
-- [count]go		Go to [count] byte in the buffer.

local function remove_mappings_basic()
  -- map("n", "gp", '"+p', { desc = "Paste from system clipboard" })
  -- -- - Paste in Visual with `P` to not copy selected text (`:h v_P`)
  -- map("x", "gp", '"+P', { desc = "Paste from system clipboard" })
  vim.keymap.del({ "n", "x" }, "gp") -- Use terminal: shift-ctrl-v

  -- Reselect latest changed, put, or yanked text
  vim.keymap.del("n", "gV") -- Not working?

  -- Search inside visually highlighted text. Use `silent = false` for it to
  -- make effect immediately.
  vim.keymap.del("x", "g/")
  --
  -- Alternative way to save and exit in Normal mode.
  -- Adding `redraw` helps with `cmdheight=0` if buffer is not modified
  vim.keymap.del({ "n", "x", "i" }, "<C-S>")
  --
  -- In nvim-0.11, gO is used for lsp.  New built-in mappings: [space and ]space
  -- if vim.fn.has("nvim-0.11") == 1 then
  --   vim.keymap.del("n", "gO")
  -- end
end

local basics = require("mini.basics")
local config = {

  options = { -- not using options in favor of own options...
    -- Basic options ('number', 'ignorecase', and many more)
    basic = false, -- true. Also optional: win_borders, extra_ui
  },

  mappings = {
    -- Basic mappings (better 'jk', save with Ctrl+S, ...)
    -- Also copy/paste with system clipboard, gy gp
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
remove_mappings_basic()
-- Mappings.windows, ctrl-hjkl will be overridden in ak.config.editor.mini_visits
