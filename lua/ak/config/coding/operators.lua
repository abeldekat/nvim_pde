--          ╭─────────────────────────────────────────────────────────╮
--          │    gr replace with register (conflicts with lsp gr)     │
--          │          gx exchange (overrides netrw mapping)          │
--          │              gs sort (overrides go sleep)               │
--          │                       g= evaluate                       │
--          │gm multiply (overrides half a screen width to the right) │
--          ╰─────────────────────────────────────────────────────────╯

-- Note: Creates mappings for normal and visual mode, not for operator pending.
--
-- From the help:
-- gx in Normal mode calls vim.ui.open() on whatever is under the cursor,
-- which shells out to your operating system’s “open” capability

local remap = function(mode, lhs_from, lhs_to)
  local keymap = vim.fn.maparg(lhs_from, mode, false, true)
  local rhs = keymap.callback or keymap.rhs
  if rhs == nil then error("Could not remap from " .. lhs_from .. " to " .. lhs_to) end
  vim.keymap.set(mode, lhs_to, rhs, { desc = keymap.desc })
end
remap("n", "gx", "gX")
remap("x", "gx", "gX")

local opts = {
  replace = { prefix = "gs" }, --> "go substitute", lsp uses gr for "go references"
  sort = { prefix = "gS" }, --> "go sort", used rarely.
}
require("mini.operators").setup(opts)
