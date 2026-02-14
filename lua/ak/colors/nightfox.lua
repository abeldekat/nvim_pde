local info = {
  name = 'nightfox',
  variants = { 'nordfox', 'nightfox', 'carbonfox', 'duskfox', 'terafox', 'dawnfox', 'dayfox' },
}
Config.add_theme_info('*fox', info, 'Nightfox variants')

local opts = {
  dim_inactive = true,
}

require('nightfox').setup({
  options = opts,
  groups = {
    all = {
      MiniJump2dSpot = { fg = 'orange', bg = nil, style = 'bold,nocombine' },
      MiniJump2dSpotAhead = { link = 'MiniJump2dSpot' },
      MiniJump2dSpotUnique = { link = 'MiniJump2dSpot' },
      MsgArea = { fg = 'syntax.comment' }, -- Area for messages and cmdline
    },
  },
})
