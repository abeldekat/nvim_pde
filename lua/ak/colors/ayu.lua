-- Not actively used...
-- Last commit downloaded: 283badaa983234c90e857c12c1f1c18e1544360a
-- Add to colors.txt: ayu

local add_toggle = require("akshared.color_toggle").add
local prefer_light = require("ak.color").prefer_light
vim.o.background = prefer_light and "light" or "dark"

-- unique colors, light is vague
add_toggle("ayu*", {
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
