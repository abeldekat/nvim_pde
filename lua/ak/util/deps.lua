--          ╭─────────────────────────────────────────────────────────╮
--          │   Purpose: Some plugins are loaded on keys or events    │
--          │         As such, they are unknown to mini.deps,         │
--          │      resulting in for example incomplete updates,       │
--          │        or loss of information in mini-deps-snap         │
--          ╰─────────────────────────────────────────────────────────╯

---@class ak.util.deps
local M = {}
local MiniDeps = require("mini.deps")
local optional_specs = {}

-- Register a plugin to packadd on keymapping or event
function M.register(spec) table.insert(optional_specs, spec) end

-- MiniDeps.add performs a packadd(), :h packadd
function M.load_registered()
  for _, spec in ipairs(optional_specs) do
    MiniDeps.add(spec)
  end
end

return M
