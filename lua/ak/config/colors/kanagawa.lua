--          ╭─────────────────────────────────────────────────────────╮
--          │        kanagawa does not support mini.statusline        │
--          ╰─────────────────────────────────────────────────────────╯

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
  overrides = function(colors)
    vim.cmd("highlight! link MiniStatuslineModeNormal StatusLine")

    if prefer_light then -- improve flashlabel
      return { Substitute = { fg = colors.theme.ui.fg_reverse, bg = colors.theme.vcs.removed } }
    end
    return {}
  end,
}

require("kanagawa").setup(opts)
