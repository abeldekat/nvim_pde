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
      -- Using MiniStatuslineDevinfo, the theme supplied by nightfox is too dark:
      MiniStatuslineModeNormal = { bg = "bg2", fg = "fg3", style = "bold" },
      MiniStatuslineFilename = { bg = "bg2", fg = "fg3" },

      MiniHipatternsFixme = { bg = "diag.error", fg = "bg", style = "bold" },
      MiniHipatternsHack = { bg = "diag.warn", fg = "bg", style = "bold" },
      MiniHipatternsTodo = { bg = "diag.info", fg = "bg", style = "bold" },
      MiniHipatternsNote = { bg = "diag.hint", fg = "bg", style = "bold" },
    },
  },
})
