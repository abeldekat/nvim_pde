--          ╭─────────────────────────────────────────────────────────╮
--          │               mini.statusline: supported                │
--          │       nightfox has themes instead of flavours...        │
--          ╰─────────────────────────────────────────────────────────╯

local Utils = require("ak.util")

Utils.color.add_toggle("*fox", {
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
      MiniJump2dSpotAhead = { link = "MiniJump2dSpot" },
      MsgArea = { fg = "syntax.comment" }, -- Area for messages and cmdline
    },
  },
})
