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

local function override_extended(on_update)
  Harpoonline.setup({
    formatter_opts = {
      extended = {
        indicators = { " j ", " k ", " l ", " h " },
        active_indicators = { "<j>", "<k>", "<l>", "<h>" },
        empty_slot = " · ",
      },
    },
    on_update = on_update,
  })
end

local function extended_shortenend(on_update)
  Harpoonline.setup({
    icon = "󰛢",
    formatter_opts = {
      extended = { -- remove all spaces...
        indicators = { "1", "2", "3", "4" },
        more_marks_indicator = "…", -- horizontal elipsis. Disable with empty string
        more_marks_active_indicator = "[…]", -- Disable with empty string
      },
    },
    on_update = on_update,
  })
end

local function custom(on_update)
  Harpoonline.setup({
    ---@param data HarpoonlineData
    ---@return string
    custom_formatter = function(data)
      return string.format(
        "%s%s%s",
        "➡️ ",
        data.list_name and string.format("%s ", data.list_name) or "",
        data.buffer_idx and string.format("%d", data.buffer_idx) or "-"
      )
    end,
    on_update = on_update,
  })
end

local flavors = {
  extended = extended,
  short = short,
  override_extended = override_extended,
  extended_shortenend = extended_shortenend,
  custom = custom,
}

---@param on_update function
function M.setup(on_update)
  --
  flavors.extended(on_update)
end

return M
