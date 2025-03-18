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

local function remove_mappings_basic() -- pre nvim-0.11
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
end

local function map(mode, lhs, rhs, opts)
  if lhs == "" then return end
  opts = vim.tbl_deep_extend("force", { silent = true }, opts or {})
  vim.keymap.set(mode, lhs, rhs, opts)
end

-- In nvim-0.11, gO is used for lsp.  Use new built-in mappings: [space and ]space
local function add_mappings_basic() -- >= nvim-0.11, copied from mini.basics
  -- Move by visible lines.
  map({ "n", "x" }, "j", [[v:count == 0 ? 'gj' : 'j']], { expr = true })
  map({ "n", "x" }, "k", [[v:count == 0 ? 'gk' : 'k']], { expr = true })

  -- Copy/paste with system clipboard ( not using the provided gp)
  map({ "n", "x" }, "gy", '"+y', { desc = "Copy to system clipboard" })
  -- From hardtime.nvim, when using gy$: Use Y instead of y$
  map({ "n", "x" }, "gY", '"+y$', { desc = "Copy (Y) to system clipboard" })
end

local skip_mappings_basic = vim.fn.has("nvim-0.11") == 1 and true or false

require("mini.basics").setup({
  -- Not using options in favor of own options...
  options = { basic = false },
  mappings = {
    -- Basic mappings (better 'jk', save with Ctrl+S, ...)
    -- Also copy/paste with system clipboard, gy gp
    basic = not skip_mappings_basic, -- especially: go and gO
    -- Prefix for mappings that toggle common options ('wrap', 'spell', ...).
    option_toggle_prefix = "", -- [[\]],  disable... See keymaps leader u
    -- Window navigation with <C-hjkl>, resize with <C-arrow>
    windows = true,
    -- Move cursor in Insert, Command, and Terminal mode with <M-hjkl>
    move_with_alt = true,
  },
  -- Autocommands. Set to `false` to disable
  -- Highlight on yank: See own options
  -- Start terminal with insert: Using toggleterm mostly
  autocommands = { basic = false },
  -- Whether to disable showing non-error feedback
  silent = false,
})

if skip_mappings_basic then
  add_mappings_basic()
else
  remove_mappings_basic() -- vim.keymap.del for mappings you don't want...
end
-- Mappings.windows, ctrl-hjkl will be overridden in ak.config.editor.mini_visits
