local Utils = require("ak.util")
local prefer_light = require("ak.color").prefer_light

Utils.color.add_toggle("tokyonight*", {
  name = "tokyonight",
  flavours = { "tokyonight-storm", "tokyonight-moon", "tokyonight-night", "tokyonight-day" },
})

-- Tokyonight has a day-brightness, default 0.3
local opts = {
  dim_inactive = true,
  style = prefer_light and "day" or "moon",
}

opts.on_highlights = function(hl, c)
  -- only needed for light theme. Normal darktheme shows white as fg:
  -- change fg = c.fg into:
  if prefer_light then
    hl.FlashLabel = { bg = c.magenta2, bold = true, fg = c.bg }
  end

  local normal_lualine_c = { bg = c.bg_statusline, fg = c.fg_sidebar }
  hl.MiniStatuslineModeNormal = normal_lualine_c -- left and right, dynamic
  hl.MiniStatuslineDevinfo = normal_lualine_c -- all inner groups
end
require("tokyonight").setup(opts)
