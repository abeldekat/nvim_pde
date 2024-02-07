--          ╭─────────────────────────────────────────────────────────╮
--          │       astrotheme does not support mini.statusline       │
--          ╰─────────────────────────────────────────────────────────╯

local Utils = require("ak.util")

Utils.color.add_toggle("astro*", {
  name = "astrotheme",
  flavours = { "astrodark", "astromars", "astrolight" },
})

local function highlights(hl, c)
  local normal_lualine_c = { fg = c.ui.active_text, bg = c.ui.statusline }
  hl.MiniStatuslineModeNormal = normal_lualine_c -- left and right, dynamic
  hl.MiniStatuslineDevinfo = normal_lualine_c -- all inner groups
end

local prefer_light = require("ak.color").prefer_light
vim.o.background = prefer_light and "light" or "dark"

local opts = {
  palette = prefer_light and "astrolight" or "astrodark",
  highlights = {
    global = {
      modify_hl_groups = highlights,
    },
  },
}

require("astrotheme").setup(opts)
