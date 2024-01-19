local Utils = require("ak.util")
local prefer_light = require("ak.color").prefer_light
Utils.color.add_toggle("gruvbox", {
  name = "gruvbox",
        -- stylua: ignore
        flavours = {
          { "dark", "soft" }, { "dark", "" }, { "dark", "hard" },
          { "light", "soft" }, { "light", "" }, { "light", "hard" },
        },
  toggle = function(flavour)
    vim.o.background = flavour[1]
    require("gruvbox").setup({ contrast = flavour[2] })
    vim.cmd.colorscheme("gruvbox")
  end,
})
vim.o.background = prefer_light and "light" or "dark"
require("gruvbox").setup({ contrast = "soft", italic = { strings = false } })
