-- Not actively used...
-- Last commit downloaded: 20c7940da844aa4f162a64e552ae3c7e9fdc3b93
-- Add to colors.txt: rose-pine

local Utils = require("ak.util")
local prefer_light = require("ak.color").prefer_light

Utils.color.add_toggle("rose-pine*", {
  name = "rose-pine",
  flavours = { "rose-pine-moon", "rose-pine-main", "rose-pine-dawn" },
})

-- Before setup, the palette is set to main_nc:
local current_nc = "#16141f"

local hl_config = {
  -- Area for messages and cmdline
  MsgArea = { fg = "muted", current = current_nc },
}

--          ╭─────────────────────────────────────────────────────────╮
--          │               functions for highlighting                │
--          │            see lualine.themes.rose-pine.lua             │
--          ╰─────────────────────────────────────────────────────────╯

local function apply_hl(highlight, palette, copy_from)
  highlight.bg = palette[copy_from.bg]
  highlight.fg = palette[copy_from.fg]
  highlight.bold = copy_from.bold
  return highlight
end

-- create initial modified hl
local function groups()
  local palette = require("rose-pine.palette")
  local result = {}
  for name, copy_from in pairs(hl_config) do -- use palette for actual colors
    result[name] = apply_hl({}, palette, copy_from)
  end
  return result
end

-- change hl when palette changes
local function before_highlight(group, highlight, palette)
  local copy_from = hl_config[group]
  if copy_from and copy_from.current ~= palette._nc then
    apply_hl(highlight, palette, copy_from)
    copy_from.current = palette._nc
  end
end

--          ╭─────────────────────────────────────────────────────────╮
--          │                          setup                          │
--          ╰─────────────────────────────────────────────────────────╯

vim.o.background = prefer_light and "light" or "dark"
local opts = {
  variant = prefer_light and "dawn" or "moon",
  dark_variant = "moon",
  disable_italics = true,
  highlight_groups = groups(),
  before_highlight = before_highlight,
}
require("rose-pine").setup(opts)
