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
    all = {
      -- left and right, dynamic
      -- the theme supplied by nightfox is too dark:
      MiniStatuslineModeNormal = { link = "MiniStatuslineModeNormal" },
      MiniStatuslineFilename = { link = "MiniStatuslineModeNormal" },

      MiniHipatternsFixme = { bg = "diag.error", fg = "bg", style = "bold" },
      MiniHipatternsHack = { bg = "diag.warn", fg = "bg", style = "bold" },
      MiniHipatternsTodo = { bg = "diag.info", fg = "bg", style = "bold" },
      MiniHipatternsNote = { bg = "diag.hint", fg = "bg", style = "bold" },
    },
  },
})
