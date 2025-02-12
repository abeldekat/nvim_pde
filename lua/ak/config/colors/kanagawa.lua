local Utils = require("ak.util")
local prefer_light = require("ak.color").prefer_light

-- good gruvbox-like light theme
-- light is lotus, dark is wave
Utils.color.add_toggle("kanagawa*", {
  name = "kanagawa",
  flavours = { "kanagawa-wave", "kanagawa-dragon", "kanagawa-lotus" },
})

vim.o.background = prefer_light and "light" or "dark"

local opts = {
  dimInactive = true,
  colors = {
    theme = {
      all = {
        ui = {
          bg_gutter = "none",
        },
      },
    },
  },
  overrides = function(c)
    local t = c.theme
    local result = {
      MsgArea = { fg = t.syn.comment }, -- theme.ui.fg_dim -- Area for messages and cmdline
    }
    return result
  end,
}

require("kanagawa").setup(opts)
