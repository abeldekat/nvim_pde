local Utils = require("ak.misc.colorutils")
local prefer_light = require("ak.misc.color").prefer_light

-- based on Leaf KDE Plasma Theme
Utils.add_toggle("leaf", {
  name = "leaf",
        -- stylua: ignore
        flavours = {
          { "dark", "low" }, { "dark", "medium" }, { "dark", "high" },
          { "light", "low" }, { "light", "medium" }, { "light", "high" },
        },
  toggle = function(flavour)
    vim.o.background = flavour[1]
    require("leaf").setup({ contrast = flavour[2] })
    vim.cmd.colorscheme("leaf")
  end,
})
vim.o.background = prefer_light and "light" or "dark"
require("leaf").setup({ contrast = "medium" })
