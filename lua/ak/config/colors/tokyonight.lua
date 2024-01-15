local Utils = require("ak.misc.colorutils")
local prefer_light = require("ak.misc.color").prefer_light

local opts = {}

Utils.add_toggle("tokyonight*", {
  name = "tokyonight",
  flavours = { "tokyonight-storm", "tokyonight-moon", "tokyonight-night", "tokyonight-day" },
})
opts.dim_inactive = true
-- Tokyonight has a day-brightness, default 0.3
opts.style = prefer_light and "day" or "moon"
-- only needed for light theme. Normal darktheme shows white as fg:
-- change fg = c.fg into:
if prefer_light then
  opts.on_highlights = function(hl, c)
    hl.FlashLabel = { bg = c.magenta2, bold = true, fg = c.bg }
  end
end
require("tokyonight").setup(opts)
