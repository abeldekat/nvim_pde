--          ╭─────────────────────────────────────────────────────────╮
--          │             mini.statusline: not supported              │
--          ╰─────────────────────────────────────────────────────────╯
local Utils = require("ak.util")
local prefer_light = require("ak.color").prefer_light

Utils.color.add_toggle("rose-pine*", {
  name = "rose-pine",
  flavours = { "rose-pine-moon", "rose-pine-main", "rose-pine-dawn" },
})

--          ╭─────────────────────────────────────────────────────────╮
--          │     constants usable to toggle the highlight groups     │
--          │                see rose-pine.palette.lua                │
--          ╰─────────────────────────────────────────────────────────╯

-- Before setup, the palette is set to main_nc:
local current_nc = "#16141f"

local hl_config = {
  -- all inner groups, same as lualine c
  MiniStatuslineFilename = { bg = "base", fg = "text", current = current_nc },

  -- left and right, dynamic, same as lualine c
  MiniStatuslineModeNormal = { bg = "base", fg = "text", current = current_nc },

  MiniStatuslineModeInsert = { bg = "foam", fg = "base", current = current_nc },
  MiniStatuslineModeVisual = { bg = "iris", fg = "base", current = current_nc },
  MiniStatuslineModeReplace = { bg = "pine", fg = "base", current = current_nc },
  MiniStatuslineModeCommand = { bg = "love", fg = "base", current = current_nc },

  -- same as insert, the approach taken in tokyonight's lualine
  MiniStatuslineModeOther = { bg = "foam", fg = "base", current = current_nc }, -- ie terminal
  MiniStatuslineInactive = { bg = "base", fg = "muted", current = current_nc },

  MiniHipatternsFixme = { bg = "love", fg = "base", bold = true, current = current_nc },
  MiniHipatternsHack = { bg = "gold", fg = "base", bold = true, current = current_nc },
  MiniHipatternsTodo = { bg = "foam", fg = "base", bold = true, current = current_nc },
  MiniHipatternsNote = { bg = "iris", fg = "base", bold = true, current = current_nc },
}

--          ╭─────────────────────────────────────────────────────────╮
--          │               functions for highlighting                │
--          │            see lualine.themes.rose-pine.lua             │
--          ╰─────────────────────────────────────────────────────────╯

-- create the highlights for mini.statusline and mini.hlpatterns
local function groups()
  -- Initially, force rose-pine to return the correct palette:
  vim.o.background = prefer_light and "light" or "dark"
  local palette = require("rose-pine.palette")

  local result = {}
  for hl_name, config in pairs(hl_config) do -- use palette for actual colors
    local new_config = { bg = palette[config.bg], fg = palette[config.fg] }
    if config.bold then new_config.bold = config.bold end
    result[hl_name] = new_config
  end
  return result
end

-- change the highlights for mini.statusline when the palette changes
local function before_highlight(group, highlight, palette)
  local config = hl_config[group]
  if config and config.current ~= palette._nc then
    highlight.bg = palette[config.bg]
    highlight.fg = palette[config.fg]
    if config.bold then highlight.bold = config.bold end
    config.current = palette._nc
  end
end

--          ╭─────────────────────────────────────────────────────────╮
--          │                          setup                          │
--          ╰─────────────────────────────────────────────────────────╯

local opts = {
  variant = prefer_light and "dawn" or "moon",
  dark_variant = "moon",
  disable_italics = true,
  highlight_groups = groups(),
  before_highlight = before_highlight,
}
require("rose-pine").setup(opts)
