local Utils = require("ak.util")
local prefer_light = require("ak.color").prefer_light
Utils.color.add_toggle("melange", {
  name = "melange",
  flavours = { "dark", "light" },
  toggle = function(flavour)
    vim.o.background = flavour
    vim.cmd.colorscheme("melange")
  end,
})
vim.o.background = prefer_light and "light" or "dark"
