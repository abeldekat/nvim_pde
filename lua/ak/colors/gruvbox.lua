-- Not actively used...
-- Last commit downloaded: 089b60e92aa0a1c6fa76ff527837cd35b6f5ac81
-- Add to colors.txt: gruvbox

local prefer_light = require('ak.color').prefer_light
vim.o.background = prefer_light and 'light' or 'dark'

local info = {
  name = 'gruvbox',
  -- stylua: ignore
  variants = {
    { "dark", "soft" }, { "dark", "" }, { "dark", "hard" },
    { "light", "soft" }, { "light", "" }, { "light", "hard" },
  },
  cb = function(variant)
    vim.o.background = variant[1]
    ---@diagnostic disable-next-line: missing-fields
    require('gruvbox').setup({ contrast = variant[2] })
    vim.cmd.colorscheme('gruvbox')
  end,
}
_G.Config.add_theme_info('gruvbox', info, 'Gruvbox variants')

_G.Config.new_autocmd('ColorScheme', 'gruvbox', function()
  local set_hl = function(name, data) vim.api.nvim_set_hl(0, name, data) end

  local fg_msg_area = vim.api.nvim_get_hl(0, { name = 'Comment' }).fg
  set_hl('MsgArea', { fg = fg_msg_area })
end, 'Gruvbox on colorscheme')

local opts = { contrast = 'soft', italic = { strings = false } }
require('gruvbox').setup(opts)
