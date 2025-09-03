-- The module has "\" mappings for toggling options like vim-unimpaired,

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
  -- Not in basics, but from From hardtime.nvim, when using gy$: Use Y instead of y$
  map({ "n", "x" }, "gY", '"+y$', { desc = "Copy (Y) to system clipboard" })

  -- Reselect latest changed, put, or yanked text
  -- Also see: https://vim.fandom.com/wiki/Selecting_your_pasted_text
  local mapping_opts = { expr = true, replace_keycodes = false, desc = "Visually select changed text" }
  map("n", "gV", '"`[" . strpart(getregtype(), 0, 1) . "`]"', mapping_opts)
end

require("mini.basics").setup({
  -- Not using options in favor of own options...
  options = { basic = false },
  mappings = {
    -- Basic mappings (better 'jk', save with Ctrl+S, ...)
    -- Also copy/paste with system clipboard, gy gp
    basic = false,
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

add_mappings_basic()
