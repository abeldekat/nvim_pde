local Utils = require("ak.misc.colorutils")
local prefer_light = require("ak.misc.color").prefer_light

-- lazygit colors are not always readable,  good light theme
Utils.add_toggle("everforest", {
  name = "everforest",
        -- stylua: ignore
        flavours = {
          { "dark", "soft" }, { "dark", "medium" }, { "dark", "hard" },
          { "light", "soft" }, { "light", "medium" }, { "light", "hard" },
        },
  toggle = function(flavour)
    vim.o.background = flavour[1]
    vim.g.everforest_background = flavour[2]
    vim.cmd.colorscheme("everforest")
  end,
})
vim.g.everforest_better_performance = 1
vim.g.everforest_enable_italic = 1
vim.o.background = prefer_light and "light" or "dark"
vim.g.everforest_background = "medium"
