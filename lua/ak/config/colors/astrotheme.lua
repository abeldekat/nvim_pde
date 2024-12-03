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
  -- hl.MiniHipatternsFixme = { fg = c.ui.base, bg = c.ui.red, bold = true }
  -- hl.MiniHipatternsHack = { fg = c.ui.base, bg = c.ui.yellow, bold = true }
  -- hl.MiniHipatternsTodo = { fg = c.ui.base, bg = c.ui.blue, bold = true }
  -- hl.MiniHipatternsNote = { fg = c.ui.base, bg = c.ui.cyan, bold = true }

  hl.MsgArea = { fg = c.syntax.comment } -- Area for messages and cmdline
end

local opts = {
  palette = prefer_light and "astrolight" or "astrodark",
  highlights = { global = { modify_hl_groups = highlights } },
}

require("astrotheme").setup(opts)
