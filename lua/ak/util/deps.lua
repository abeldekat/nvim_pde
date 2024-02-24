--          ╭─────────────────────────────────────────────────────────╮
--          │                Module patching mini.deps                │
--          │                                                         │
--          │   Purpose: Some plugins are loaded on keys or events    │
--          │         As such, they are unknown to mini.deps,         │
--          │      resulting in for example incomplete updates,       │
--          │        or loss of information in mini-deps-snap         │
--          │         Solution: Decorate some of the methods          │
--          │       to first add those plugins before executing       │
--          ╰─────────────────────────────────────────────────────────╯

---@class ak.util.deps
local M = {}
local MiniDeps = require("mini.deps")
local optional_specs = {}

-- register a plugin to add() later
function M.register(spec) table.insert(optional_specs, spec) end

-- patch MiniDeps methods
-- MiniDeps.add performs a packadd(), :h packadd
function M.patch()
  local function decorate(org_cmd)
    return function(...)
      vim.tbl_map(function(spec)
        MiniDeps.add(spec) --
      end, optional_specs)

      -- It's not necessary to packadd multiple times in the same session:
      optional_specs = {}

      -- Run the method
      org_cmd(...)
    end
  end

  MiniDeps.snap_save = decorate(MiniDeps.snap_save)
  MiniDeps.snap_load = decorate(MiniDeps.snap_load)
  MiniDeps.update = decorate(MiniDeps.update)
  MiniDeps.clean = decorate(MiniDeps.clean)
end

return M
