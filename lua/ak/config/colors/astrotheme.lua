--          ╭─────────────────────────────────────────────────────────╮
--          │             mini.statusline: not supported              │
--          ╰─────────────────────────────────────────────────────────╯
local Utils = require("ak.util")
local prefer_light = require("ak.color").prefer_light
vim.o.background = prefer_light and "light" or "dark"

Utils.color.add_toggle("astro*", {
  name = "astrotheme",
  flavours = { "astrodark", "astromars", "astrolight", "astrojupiter" },
})

local function highlights(hl, c)
  hl.MiniStatuslineInactive = { fg = c.ui.text_inactive, bg = c.ui.base }
  -- lualine_c:
  hl.MiniStatuslineFilename = { fg = c.ui.active_text, bg = c.ui.statusline } -- all inner groups
  hl.MiniStatuslineModeNormal = { fg = c.ui.active_text, bg = c.ui.statusline } -- left and right, dynamic
  --
  hl.MiniStatuslineModeInsert = { fg = c.ui.base, bg = c.ui.green }
  hl.MiniStatuslineModeReplace = { fg = c.ui.base, bg = c.ui.red }
  hl.MiniStatuslineModeVisual = { fg = c.ui.base, bg = c.ui.purple }
  hl.MiniStatuslineModeCommand = { fg = c.ui.base, bg = c.ui.yellow }
  hl.MiniStatuslineModeOther = { fg = c.ui.base, bg = c.ui.orange }

  hl.MiniHipatternsFixme = { fg = c.ui.base, bg = c.ui.red, bold = true }
  hl.MiniHipatternsHack = { fg = c.ui.base, bg = c.ui.yellow, bold = true }
  hl.MiniHipatternsTodo = { fg = c.ui.base, bg = c.ui.blue, bold = true }
  hl.MiniHipatternsNote = { fg = c.ui.base, bg = c.ui.cyan, bold = true }
end

local opts = {
  palette = prefer_light and "astrolight" or "astrodark",
  highlights = { global = { modify_hl_groups = highlights } },
}

require("astrotheme").setup(opts)
