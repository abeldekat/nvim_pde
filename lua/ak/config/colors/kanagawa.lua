--          ╭─────────────────────────────────────────────────────────╮
--          │             mini.statusline: not supported              │
--          ╰─────────────────────────────────────────────────────────╯
local Utils = require("ak.util")
local prefer_light = require("ak.color").prefer_light

-- good gruvbox-like light theme
-- light is lotus, dark is wave
Utils.color.add_toggle("kanagawa*", {
  name = "kanagawa",
  flavours = { "kanagawa-wave", "kanagawa-dragon", "kanagawa-lotus" },
})

vim.o.background = prefer_light and "light" or "dark"

local opts = {
  overrides = function(c)
    local result = {
      MiniStatusLineModeInactive = { fg = c.theme.ui.fg_dim, bg = c.theme.ui.bg_m3 },
      MiniStatusLineFilename = { fg = c.theme.syn.fun, bg = c.theme.ui.bg_p1 }, -- lualine_b better fg
      --
      MiniStatusLineModeNormal = { fg = c.theme.syn.fun, bg = c.theme.ui.bg_p1 }, -- lualine_b better fg
      MiniStatusLineModeInsert = { fg = c.theme.ui.bg, bg = c.theme.diag.ok },
      MiniStatusLineModeReplace = { fg = c.theme.ui.bg, bg = c.theme.syn.constant },
      MiniStatusLineModeVisual = { fg = c.theme.ui.bg, bg = c.theme.syn.keyword },
      MiniStatusLineModeCommand = { fg = c.theme.ui.bg, bg = c.theme.syn.operator },
      MiniStatusLineModeOther = { fg = c.theme.ui.bg, bg = c.theme.diag.ok }, -- added, same as insert

      MiniHipatternsFixme = { bg = c.theme.diag.error, fg = c.theme.ui.bg, bold = true },
      MiniHipatternsHack = { bg = c.theme.diag.warning, fg = c.theme.ui.bg, bold = true },
      MiniHipatternsTodo = { bg = c.theme.diag.info, fg = c.theme.ui.bg, bold = true },
      MiniHipatternsNote = { bg = c.theme.diag.hint, fg = c.theme.ui.bg, bold = true },
    }

    return result
  end,
}

require("kanagawa").setup(opts)
