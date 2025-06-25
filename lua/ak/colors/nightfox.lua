--          ╭─────────────────────────────────────────────────────────╮
--          │       nightfox has themes instead of flavours...        │
--          ╰─────────────────────────────────────────────────────────╯

local add_toggle = require("akshared.color_toggle").add

add_toggle("*fox", {
  name = "nightfox",
  flavours = { "nordfox", "nightfox", "carbonfox", "duskfox", "terafox", "dawnfox", "dayfox" },
})

local opts = {
  dim_inactive = true,
}

require("nightfox").setup({
  options = opts,
  groups = {
    all = {
      MiniJump2dSpot = { fg = "orange", bg = nil, style = "bold,nocombine" },
      MiniJump2dSpotAhead = { link = "MiniJump2dSpot" },
      MiniJump2dSpotUnique = { link = "MiniJump2dSpot" },
      MsgArea = { fg = "syntax.comment" }, -- Area for messages and cmdline
    },
  },
})
