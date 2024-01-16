local Utils = require("ak.misc.colorutils")
local prefer_light = require("ak.misc.color").prefer_light

Utils.add_toggle("astro*", {
  name = "astrotheme",
  flavours = { "astrodark", "astromars", "astrolight" },
})
vim.o.background = prefer_light and "light" or "dark"
require("astrotheme").setup({
  palette = prefer_light and "astrolight" or "astrodark",
})
