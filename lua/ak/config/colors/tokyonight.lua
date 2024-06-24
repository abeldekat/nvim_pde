--          ╭─────────────────────────────────────────────────────────╮
--          │               mini.statusline: supported                │
--          ╰─────────────────────────────────────────────────────────╯
local Utils = require("ak.util")
local prefer_light = require("ak.color").prefer_light

Utils.color.add_toggle("tokyonight*", {
  name = "tokyonight",
  flavours = { "tokyonight-storm", "tokyonight-moon", "tokyonight-night", "tokyonight-day" },
})

local opts = {
  dim_inactive = true,
  style = prefer_light and "day" or "storm",
  on_highlights = function(hl, c)
    -- Careful: Do not use the same table instance twice!
    hl.MiniStatuslineModeNormal = { bg = c.bg_statusline, fg = c.fg_sidebar } -- left and right, dynamic
    hl.MiniStatuslineFilename = { bg = c.bg_statusline, fg = c.fg_sidebar } -- all inner groups
    hl.MsgArea = { fg = c.comment } -- fg_dark: -- Area for messages and cmdline
  end,
}

require("tokyonight").setup(opts)
