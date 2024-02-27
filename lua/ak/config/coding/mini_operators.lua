--          ╭─────────────────────────────────────────────────────────╮
--          │    gr replace with register (conflicts with lsp gr)     │
--          │          gx exchange (overrides netrw mapping)          │
--          │              gs sort (overrides go sleep)               │
--          │                       g= evaluate                       │
--          │gm multiply (overrides half a screen width to the right) │
--          ╰─────────────────────────────────────────────────────────╯

local function get_opts()
  local opts = {
    replace = { prefix = "gs" }, --> "go substitute", lsp uses gr, go referenceDs
    sort = { prefix = "gS" }, --> "go sort"
  }
  return opts
end
require("mini.operators").setup(get_opts())
