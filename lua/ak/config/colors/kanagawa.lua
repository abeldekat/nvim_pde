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
  dimInactive = true,

  colors = {
    theme = {
      all = {
        ui = {
          bg_gutter = "none",
        },
      },
    },
  },
  overrides = function(c)
    local t = c.theme
    local result = {
      MiniStatusLineModeInactive = { fg = t.ui.fg_dim, bg = t.ui.bg_m3 },
      MiniStatusLineFilename = { fg = t.syn.fun, bg = t.ui.bg_p1 }, -- lualine_b better fg
      --
      MiniStatusLineModeNormal = { fg = t.syn.fun, bg = t.ui.bg_p1 }, -- lualine_b better fg
      MiniStatusLineModeInsert = { fg = t.ui.bg, bg = t.diag.ok },
      MiniStatusLineModeReplace = { fg = t.ui.bg, bg = t.syn.constant },
      MiniStatusLineModeVisual = { fg = t.ui.bg, bg = t.syn.keyword },
      MiniStatusLineModeCommand = { fg = t.ui.bg, bg = t.syn.operator },
      MiniStatusLineModeOther = { fg = t.ui.bg, bg = t.diag.ok }, -- added, same as insert

      MiniHipatternsFixme = { bg = t.diag.error, fg = t.ui.bg, bold = true },
      MiniHipatternsHack = { bg = t.diag.warning, fg = t.ui.bg, bold = true },
      MiniHipatternsTodo = { bg = t.diag.info, fg = t.ui.bg, bold = true },
      MiniHipatternsNote = { bg = t.diag.hint, fg = t.ui.bg, bold = true },
    }

    return result
  end,
}

require("kanagawa").setup(opts)
