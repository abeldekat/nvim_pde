local Utils = require("ak.util")
local prefer_light = require("ak.color").prefer_light

Utils.color.add_toggle("edge", {
  name = "edge",
        -- stylua: ignore
        flavours = {
          { "dark", "default" }, { "dark", "aura" }, { "dark", "neon" },
          { "light", "default" },
        },
  toggle = function(flavour)
    vim.o.background = flavour[1]
    vim.g.edge_style = flavour[2]
    vim.cmd.colorscheme("edge")
  end,
})
vim.g.edge_better_performance = 1
vim.g.edge_enable_italic = 1
vim.o.background = prefer_light and "light" or "dark"
vim.g.edge_style = "default"
