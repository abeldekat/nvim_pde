--          ╭─────────────────────────────────────────────────────────╮
--          │             mini.statusline: not supported              │
--          ╰─────────────────────────────────────────────────────────╯
local Utils = require("ak.util")
local prefer_light = require("ak.color").prefer_light
vim.o.background = prefer_light and "light" or "dark"

-- unique colors, light is vague
Utils.color.add_toggle("ayu*", {
  name = "ayu",
  flavours = { "ayu-mirage", "ayu-dark", "ayu-light" },
})

require("ayu").setup({
  mirage = true,
  overrides = function()
    local c = require("ayu.colors")
    return {
      MiniStatusLineModeInactive = { fg = c.fg, bg = c.panel_border },
      MiniStatusLineFilename = { fg = c.fg, bg = c.panel_border }, --lualine_c
      --
      MiniStatusLineModeNormal = { fg = c.fg, bg = c.panel_border }, -- lualine_c
      MiniStatusLineModeInsert = { fg = c.bg, bg = c.string },
      MiniStatusLineModeReplace = { fg = c.bg, bg = c.markup },
      MiniStatusLineModeVisual = { fg = c.bg, bg = c.accent },
      MiniStatusLineModeCommand = { fg = c.bg, bg = c.string }, -- added, same as insert
      MiniStatusLineModeOther = { fg = c.bg, bg = c.string }, -- added, same as insert
    }
  end,
})
