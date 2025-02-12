--          ╭─────────────────────────────────────────────────────────╮
--          │    gr replace with register (conflicts with lsp gr)     │
--          │          gx exchange (overrides netrw mapping)          │
--          │              gs sort (overrides go sleep)               │
--          │                       g= evaluate                       │
--          │gm multiply (overrides half a screen width to the right) │
--          ╰─────────────────────────────────────────────────────────╯

local opts = {
  replace = { prefix = "gs" }, --> "go substitute", lsp uses gr for "go references"
  sort = { prefix = "gS" }, --> "go sort"
}
require("mini.operators").setup(opts)
