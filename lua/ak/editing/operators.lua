--          ╭─────────────────────────────────────────────────────────╮
--          │    gr replace with register (conflicts with lsp gr)     │
--          │          gx exchange (overrides netrw mapping)          │
--          │              gs sort (overrides go sleep)               │
--          │                       g= evaluate                       │
--          │gm multiply (overrides half a screen width to the right) │
--          ╰─────────────────────────────────────────────────────────╯

-- Note: Creates mappings for normal and visual mode, not for operator pending.
--
-- Mini.operators remaps original gx automatically to gX
-- From the help:
-- gx in Normal mode calls vim.ui.open() on whatever is under the cursor,
-- which shells out to your operating system’s “open” capability
require("mini.operators").setup({
  replace = { prefix = "gs" }, --> "go substitute", lsp uses gr for "go references"
  sort = { prefix = "gS" }, --> "go sort", used rarely.
})

-- Discussion 1835 duplicate and comment:
vim.keymap.set("n", "gCC", "gmmgcck", { remap = true, desc = "Duplicate and comment line" })
