-- Not actively used...
-- Last commit downloaded: cddfb6e61f4c92f22b1ddce7d60e32688d700ed8
-- Add to colors.txt: solarized8_flat

--          ╭─────────────────────────────────────────────────────────╮
--          │             mini.statusline: not supported              │
--          ╰─────────────────────────────────────────────────────────╯

-- Mini.pick current line not different...

local prefer_light = require('ak.color').prefer_light
vim.o.background = prefer_light and 'light' or 'dark'

local info = {
  name = 'solarized8',
  -- stylua: ignore
  variants = { -- solarized8_high not used
    { "dark", "solarized8_flat" }, { "dark", "solarized8_low" }, { "dark", "solarized8" },
    { "light", "solarized8_flat" }, { "light", "solarized8_low" }, { "light", "solarized8" },
  },
  cb = function(variant)
    vim.o.background = variant[1]
    vim.cmd.colorscheme(variant[2])
  end,
}
_G.Config.add_theme_info('solarized8*', info, 'Solarized variants')

_G.Config.new_autocmd('ColorScheme', 'solarized8*', function()
  local set_hl = function(hl, data) vim.api.nvim_set_hl(0, hl, data) end
  local fg_msg_area = vim.api.nvim_get_hl(0, { name = 'Comment' }).fg
  set_hl('MsgArea', { fg = fg_msg_area }) -- Area for messages and cmdline
end, 'Solarized8 on colorscheme')
