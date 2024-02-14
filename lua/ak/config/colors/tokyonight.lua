--          ╭─────────────────────────────────────────────────────────╮
--          │               mini.statusline: supported                │
--          ╰─────────────────────────────────────────────────────────╯
local Utils = require("ak.util")
local prefer_light = require("ak.color").prefer_light

Utils.color.add_toggle("tokyonight*", {
  name = "tokyonight",
  flavours = { "tokyonight-storm", "tokyonight-moon", "tokyonight-night", "tokyonight-day" },
})

-- Tokyonight has a day-brightness, default 0.3
local opts = {
  dim_inactive = true,
  style = prefer_light and "day" or "storm",
  on_highlights = function(hl, c)
    if prefer_light then
      -- only needed for light theme. Normal darktheme shows white as fg:
      -- change fg = c.fg into:
      hl.FlashLabel = { bg = c.magenta2, bold = true, fg = c.bg }
    end

    -- Careful: Do not use the same table instance twice!
    -- The default colors configured for mini.statusline are lighter
    -- Use the lualine_c variant:
    hl.MiniStatuslineModeNormal = { bg = c.bg_statusline, fg = c.fg_sidebar } -- left and right, dynamic
    hl.MiniStatuslineFilename = { bg = c.bg_statusline, fg = c.fg_sidebar } -- all inner groups
  end,
}

require("tokyonight").setup(opts)
