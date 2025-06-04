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
      MsgArea = { fg = "syntax.comment" }, -- Area for messages and cmdline
    },
  },
})
