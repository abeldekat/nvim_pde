local prefer_light = require('ak.color').prefer_light
local bamboo = require('bamboo')
vim.o.background = prefer_light and 'light' or 'dark'

local info = {
  name = 'bamboo',
  variants = { 'dummy' }, -- irrelevant, has builtin toggle
  cb = function() bamboo.toggle() end,
}
_G.Config.add_theme_info('bamboo*', info, 'Bamboo dummy variants')

-- M.styles_list = { 'vulgaris', 'multiplex', 'light' }
-- multiplex is greener.
bamboo.setup({
  dim_inactive = true,
  highlights = {
    MsgArea = { fg = '$grey' }, -- Area for messages and cmdline
    MiniJump2dSpot = { fg = '$orange', bg = nil, bold = true, nocombine = true }, -- reddish
    MiniJump2dSpotAhead = { link = 'MiniJump2dSpot' },
    MiniJump2dSpotUnique = { link = 'MiniJump2dSpot' },
  },
})
