--          ╭─────────────────────────────────────────────────────────╮
--          │                       Harpoonline                       │
--          ╰─────────────────────────────────────────────────────────╯
local M = {}
local Harpoonline = require("harpoonline")

local function extended(on_update)
  Harpoonline.setup({
    on_update = on_update,
  })
end

local function short(on_update)
  Harpoonline.setup({
    formatter = "short",
    on_update = on_update,
  })
end

local function override(on_update)
  ---@type HarpoonlineBuiltinOptionsExtended
  local opts = {
    indicators = { "j", "k", "l", "h" },
    active_indicators = { "<j>", "<k>", "<l>", "<h>" },
    separator = " ",
    empty_slot = "",
    more_marks_indicator = "",
    more_marks_active_indicator = "",
  }
  Harpoonline.setup({
    custom_formatter = Harpoonline.gen_override("extended", opts),
    on_update = on_update,
  })
end

local function custom(on_update)
  Harpoonline.setup({
    custom_formatter = Harpoonline.gen_formatter(
      ---@param data HarpoonLineData
      ---@return string
      function(data)
        return string.format(
          "%s%s%s",
          "➡️ ",
          data.list_name and string.format("%s ", data.list_name) or "",
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
