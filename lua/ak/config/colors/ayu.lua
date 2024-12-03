--          ╭─────────────────────────────────────────────────────────╮
--          │             mini.statusline: not supported              │
--          ╰─────────────────────────────────────────────────────────╯
local Utils = require("ak.util")
local prefer_light = require("ak.color").prefer_light
vim.o.background = prefer_light and "light" or "dark"

-- unique colors, light is vague
Utils.color.add_toggle("ayu*", {
  name = "ayu",
  flavours = { "ayu-mirage", "ayu-dark", "ayu-light" },
})

require("ayu").setup({
  mirage = true,
  -- overrides = function()
  --   local c = require("ayu.colors")
  --   return {
  --     MiniHipatternsFixme = { fg = c.bg, bg = c.error, bold = true },
  --     MiniHipatternsHack = { fg = c.bg, bg = c.keyword, bold = true },
  --     MiniHipatternsTodo = { fg = c.bg, bg = c.tag, bold = true },
  --     MiniHipatternsNote = { fg = c.bg, bg = c.regexp, bold = true },
  --   }
  -- end,
})
