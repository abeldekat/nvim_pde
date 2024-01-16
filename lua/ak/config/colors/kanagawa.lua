local Utils = require("ak.misc.colorutils")
local prefer_light = require("ak.misc.color").prefer_light

-- good gruvbox-like light theme
-- light is lotus, dark is wave
Utils.add_toggle("kanagawa*", {
  name = "kanagawa",
  flavours = { "kanagawa-wave", "kanagawa-dragon", "kanagawa-lotus" },
})
vim.o.background = prefer_light and "light" or "dark"
local opts = prefer_light
    and {
      overrides = function(colors)
        return { -- Improve FlashLabel:
          -- Substitute = { fg = theme.ui.fg, bg = theme.vcs.removed },
          Substitute = { fg = colors.theme.ui.fg_reverse, bg = colors.theme.vcs.removed },
        }
      end,
    }
  or {}
require("kanagawa").setup(opts)
