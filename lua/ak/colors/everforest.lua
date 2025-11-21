local prefer_light = require('ak.color').prefer_light
local name = 'everforest'

local info = {
  name = name,
  -- stylua: ignore
  variants = {
    { "dark", "soft" }, { "dark", "medium" }, { "dark", "hard" },
    { "light", "soft" }, { "light", "medium" }, { "light", "hard" },
  },
  cb = function(variant)
    vim.o.background = variant[1]
    vim.g.everforest_background = variant[2]
    vim.cmd.colorscheme(name)
  end,
}
_G.Config.add_theme_info(name, info, 'Everforest variants')

_G.Config.new_autocmd('ColorScheme', 'everforest', function()
  local config = vim.fn['everforest#get_configuration']()
  local palette = vim.fn['everforest#get_palette'](config.background, config.colors_override)
  local set_hl = vim.fn['everforest#highlight'] -- group fg bg

  -- without undercurl:
  set_hl('ErrorText', palette.none, palette.none, 'NONE', palette.red)
  set_hl('WarningText', palette.none, palette.none, 'NONE', palette.yellow)
  set_hl('InfoText', palette.none, palette.none, 'NONE', palette.blue)
  set_hl('HintText', palette.none, palette.none, 'NONE', palette.green)

  set_hl('DiagnosticError', palette.red, palette.none)
  set_hl('DiagnosticWarn', palette.yellow, palette.none)
  set_hl('DiagnosticInfo', palette.blue, palette.none)
  set_hl('DiagnosticHint', palette.green, palette.none)

  set_hl('MiniJump2dSpot', palette.orange, palette.none, 'bold,nocombine')
  -- set_hl('MiniJump2dSpotAhead', palette.orange, palette.none, 'bold,nocombine')
  -- set_hl('MiniJump2dSpotUnique', palette.orange, palette.none, 'bold,nocombine')
  set_hl('MiniJump2dDim', palette.grey1, palette.none) -- comment color, no italic

  set_hl('MsgArea', palette.grey0, palette.none) -- Area for messages and cmdline
end, 'Everforest on colorscheme')

vim.g.everforest_better_performance = 1
vim.g.everforest_enable_italic = 1
-- vim.g.everforest_disable_italic_comment = 1
vim.g.everforest_dim_inactive_windows = 1
vim.g.everforest_background = 'medium'

vim.o.background = prefer_light and 'light' or 'dark'
