local Utils = require("ak.util")
local prefer_light = require("ak.color").prefer_light

-- unique colors, light is vague
Utils.color.add_toggle("ayu*", {
  name = "ayu",
  flavours = { "ayu-mirage", "ayu-dark", "ayu-light" },
})
vim.o.background = prefer_light and "light" or "dark"
require("ayu").setup({ mirage = true, overrides = {} })
