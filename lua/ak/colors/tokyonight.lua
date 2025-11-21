local prefer_light = require('ak.color').prefer_light

local info = {
  name = 'tokyonight',
  variants = { 'tokyonight-storm', 'tokyonight-moon', 'tokyonight-night', 'tokyonight-day' },
}
_G.Config.add_theme_info('tokyonight*', info, 'Tokyonight variants')

-- These groups from tokyonight.groups.init are always included!
-- local groups = { base = true, kinds = true, semantic_tokens = true, treesitter = true }
local plugins = {
  all = false, -- the default is true when not using lazy.nvim
  auto = false, -- only supported for lazy.nvim
  --
  -- ["blink_cmp"] = true,
  ['render-markdown'] = true,
  -- ["leap"] = true,
  ['mini_animate'] = true,
  ['mini_clue'] = true,
  ['mini_completion'] = true,
  ['mini_cursorword'] = true,
  ['mini_deps'] = true,
  ['mini_diff'] = true,
  ['mini_files'] = true,
  ['mini_hipatterns'] = true,
  ['mini_icons'] = true,
  ['mini_indentscope'] = true,
  ['mini_notify'] = true,
  ['mini_operators'] = true,
  ['mini_pick'] = true,
  ['mini_starter'] = true,
  ['mini_statusline'] = true,
  ['mini_surround'] = true,
  -- ["mini_test"] = false,
  -- ["mini_trailspace"] = false,
  ['neotest'] = true,
  ['dap'] = true,
  ['treesitter-context'] = true,
}

local opts = {
  dim_inactive = true,
  plugins = plugins,
  on_highlights = function(hl, c)
    hl.MiniJump2dSpot = { fg = c.orange, bg = nil, bold = true, nocombine = true }
    hl.MiniJump2dSpotAhead = { link = 'MiniJump2dSpot' }
    hl.MiniJump2dSpotUnique = { link = 'MiniJump2dSpot' }
    hl.MiniJump2dDim = { fg = c.comment } -- comment color, no italic

    -- Careful: Do not use the same table instance twice!
    hl.MsgArea = { fg = c.comment } -- fg_dark: -- Area for messages and cmdline
  end,
  style = prefer_light and 'day' or 'moon',
}

require('tokyonight').setup(opts)
