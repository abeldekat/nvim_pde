local Utils = require("ak.util")
local prefer_light = require("ak.color").prefer_light

Utils.color.add_toggle("rose-pine*", {
  name = "rose-pine",
  flavours = { "rose-pine-moon", "rose-pine-main", "rose-pine-dawn" },
})
require("rose-pine").setup({
  variant = prefer_light and "dawn" or "moon",
  disable_italics = true,
})
