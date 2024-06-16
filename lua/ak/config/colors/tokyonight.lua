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
    -- Careful: Do not use the same table instance twice!
    -- The default colors configured for mini.statusline are lighter
    -- Use the lualine_c variant:
    hl.MiniStatuslineModeNormal = { bg = c.bg_statusline, fg = c.fg_sidebar } -- left and right, dynamic
    hl.MiniStatuslineFilename = { bg = c.bg_statusline, fg = c.fg_sidebar } -- all inner groups

    hl.MiniHipatternsFixme = { bg = hl.DiagnosticError.fg, fg = c.bg, bold = true }
    hl.MiniHipatternsHack = { bg = hl.DiagnosticWarn.fg, fg = c.bg, bold = true }
    hl.MiniHipatternsTodo = { bg = hl.DiagnosticInfo.fg, fg = c.bg, bold = true }
    hl.MiniHipatternsNote = { bg = hl.DiagnosticHint.fg, fg = c.bg, bold = true }
  end,
}

require("tokyonight").setup(opts)
