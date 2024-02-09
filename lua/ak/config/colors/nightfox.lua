--          ╭─────────────────────────────────────────────────────────╮
--          │               mini.statusline: supported                │
--          │       nightfox has themes instead of flavours...        │
--          ╰─────────────────────────────────────────────────────────╯
local Utils = require("ak.util")

Utils.color.add_toggle("*fox", {
  name = "nightfox",
  -- "carbonfox", "dayfox",
  flavours = { "nordfox", "nightfox", "duskfox", "terafox", "dawnfox" },
})

local opts = {
  dim_inactive = true,
}

require("nightfox").setup({
  options = opts,
  groups = {
    -- left and right, dynamic
    all = { MiniStatuslineModeNormal = { link = "MiniStatuslineFilename" } },
  },
})
