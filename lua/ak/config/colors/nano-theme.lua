-- very few colors, solarized look
local Utils = require("ak.util")
local prefer_light = require("ak.color").prefer_light

Utils.color.add_toggle("nano-theme", {
  name = "nano-theme",
  flavours = { "dark", "light" },
  toggle = function(flavour)
    vim.o.background = flavour
    vim.cmd.colorscheme("nano-theme")
  end,
})
vim.o.background = prefer_light and "light" or "dark"
