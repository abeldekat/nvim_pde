--          ╭─────────────────────────────────────────────────────────╮
--          │             mini.statusline: not supported              │
--          ╰─────────────────────────────────────────────────────────╯
local Utils = require("ak.util")
local prefer_light = require("ak.color").prefer_light
vim.o.background = prefer_light and "light" or "dark"

Utils.color.add_toggle("astro*", {
  name = "astrotheme",
  flavours = { "astrodark", "astromars", "astrolight" },
})

local function highlights(hl, c) -- lualine_c
  hl.MiniStatuslineModeNormal = { fg = c.ui.active_text, bg = c.ui.statusline } -- left and right, dynamic
  hl.MiniStatuslineFilename = { fg = c.ui.active_text, bg = c.ui.statusline } -- all inner groups
end

local opts = {
  palette = prefer_light and "astrolight" or "astrodark",
  highlights = { global = { modify_hl_groups = highlights } },
}

require("astrotheme").setup(opts)
