--          ╭─────────────────────────────────────────────────────────╮
--          │               mini.statusline: supported                │
--          │           the theme is forked from tokyonight           │
--          ╰─────────────────────────────────────────────────────────╯
local Utils = require("ak.util")
local prefer_light = require("ak.color").prefer_light

Utils.color.add_toggle("solarized-osaka*", {
  name = "solarized-osaka",
  flavours = { "solarized-osaka-storm", "solarized-osaka-moon", "solarized-osaka-night", "solarized-osaka-day" },
})

local opts = {
  dim_inactive = true,
  style = prefer_light and "day" or "moon",
  on_highlights = function(hl, c)
    -- Careful: Do not use the same table instance twice!
    -- The default colors configured for mini.statusline are lighter
    -- Use the lualine variant:
    hl.MiniStatuslineModeNormal = { bg = c.bg_statusline, fg = c.fg_sidebar } -- left and right, dynamic
    hl.MiniStatuslineFilename = { bg = c.bg_statusline, fg = c.fg_sidebar } -- all inner groups

    hl.MiniHipatternsFixme = { bg = hl.DiagnosticError.fg, fg = c.bg, bold = true }
    hl.MiniHipatternsHack = { bg = hl.DiagnosticWarn.fg, fg = c.bg, bold = true }
    hl.MiniHipatternsTodo = { bg = hl.DiagnosticInfo.fg, fg = c.bg, bold = true }
    hl.MiniHipatternsNote = { bg = hl.DiagnosticHint.fg, fg = c.bg, bold = true }
  end,
}

require("solarized-osaka").setup(opts)
