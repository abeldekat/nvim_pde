local Utils = require("ak.misc.colorutils")
local prefer_light = require("ak.misc.color").prefer_light

Utils.add_toggle("rose-pine*", {
  name = "rose-pine",
  flavours = { "rose-pine-moon", "rose-pine-main", "rose-pine-dawn" },
})
require("rose-pine").setup({
  variant = prefer_light and "dawn" or "moon",
  disable_italics = true,
})
