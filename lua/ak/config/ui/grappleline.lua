--          ╭─────────────────────────────────────────────────────────╮
--          │                       Grappleline                       │
--          ╰─────────────────────────────────────────────────────────╯
local M = {}
local Grappleline = require("grappleline")

local function extended(on_update)
  Grappleline.setup({
    override_scope_names = { git = "", git_branch = "dev" },
    on_update = on_update,
  })
end

local function short(on_update)
  Grappleline.setup({
    override_scope_names = { git = "", git_branch = "dev" },
    formatter = "short",
    on_update = on_update,
  })
end

local function override(on_update)
  ---@type GrapplelineBuiltinOptionsExtended
  local opts = {
    indicators = { " j ", " k ", " l ", " h " },
    active_indicators = { "<j>", "<k>", "<l>", "<h>" },
    empty_slot = " · ",
  }
  Grappleline.setup({
    custom_formatter = Grappleline.gen_override("extended", opts),
    on_update = on_update,
  })
end

local function custom(on_update)
  Grappleline.setup({
    custom_formatter = Grappleline.gen_formatter(
      ---@param data GrapplelineData
      ---@return string
      function(data)
        return string.format(
          "%s%s%s",
          "➡️ ",
          data.scope_name and string.format("%s ", data.scope_name) or "",
          data.buffer_idx and string.format("%d", data.buffer_idx) or "-"
        )
      end
    ),
    on_update = on_update,
  })
end

local flavors = {
  extended = extended,
  short = short,
  override = override,
  custom = custom,
}

---@param on_update function
function M.setup(on_update)
  --
  flavors.extended(on_update)
end

return M
