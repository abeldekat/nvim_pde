local Utils = require("ak.util")
local prefer_light = require("ak.color").prefer_light

Utils.color.add_toggle("solarized-osaka*", { -- only the bg is important.
  name = "solarized-osaka",
  flavours = { "solarized-osaka-storm", "solarized-osaka-day" },
})

local opts = {
  dim_inactive = true,
  style = prefer_light and "day" or "storm",
  on_highlights = function(hl, _) -- c
    hl.MiniStatuslineModeNormal = { link = "MiniStatuslineFilename" }
  end,
}

require("solarized-osaka").setup(opts)
