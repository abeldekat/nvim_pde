-- Not actively used...
-- Last commit downloaded: 67a74c275d1116d575ab25485d1bfa6b2a9c38a6
-- Add to colors.txt: onedark

local name = 'onedark'
local onedark = require('onedark')

local info = {
  name = name,
  variants = { 'dummy' }, -- irrelevant, has builtin toggle
  cb = function() onedark.toggle() end,
}
_G.Config.add_theme_info(name, info, 'Onedark dummy variants')

_G.Config.new_autocmd('ColorScheme', name, function()
  local hl_for_msg_area = vim.api.nvim_get_hl(0, { name = 'Comment', link = false })
  vim.api.nvim_set_hl(0, 'MsgArea', { fg = hl_for_msg_area.fg }) -- Area for messages and cmdline
end, 'Onedark on colorscheme')

onedark.setup({ -- the default is dark
  toggle_style_list = { 'warm', 'warmer', 'light', 'dark', 'darker', 'cool', 'deep' },
  style = 'dark', -- ignored on startup, onedark.load must be used.
})
