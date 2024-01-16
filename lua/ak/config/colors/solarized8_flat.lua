local Utils = require("ak.misc.colorutils")
local prefer_light = require("ak.misc.color").prefer_light
Utils.add_toggle("solarized8*", {
  name = "solarized8",
        -- stylua: ignore
        flavours = { -- solarized8_high not used
          { "dark", "solarized8_flat" }, { "dark", "solarized8_low" }, { "dark", "solarized8" },
          { "light", "solarized8_flat" }, { "light", "solarized8_low" }, { "light", "solarized8" },
        },
  toggle = function(flavour)
    vim.o.background = flavour[1]
    vim.cmd.colorscheme(flavour[2])
  end,
})
vim.o.background = prefer_light and "light" or "dark"
