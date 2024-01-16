-- very few colors, solarized look
local Utils = require("ak.misc.colorutils")
local prefer_light = require("ak.misc.color").prefer_light
Utils.add_toggle("nano-theme", {
  name = "nano-theme",
  flavours = { "dark", "light" },
  toggle = function(flavour)
    vim.o.background = flavour
    vim.cmd.colorscheme("nano-theme")
  end,
})
vim.o.background = prefer_light and "light" or "dark"
