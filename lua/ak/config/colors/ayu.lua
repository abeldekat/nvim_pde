local Utils = require("ak.misc.colorutils")
local prefer_light = require("ak.misc.color").prefer_light

-- unique colors, light is vague
Utils.add_toggle("ayu*", {
  name = "ayu",
  flavours = { "ayu-mirage", "ayu-dark", "ayu-light" },
})
vim.o.background = prefer_light and "light" or "dark"
require("ayu").setup({ mirage = true, overrides = {} })
