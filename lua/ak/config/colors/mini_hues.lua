local Utils = require("ak.util")
local prefer_light = require("ak.color").prefer_light
vim.o.background = prefer_light and "light" or "dark"

Utils.color.add_toggle("*hue", { -- toggle randoms with leader h
  name = "mini_hues",
  flavours = { "randomhue" },
})

vim.api.nvim_create_autocmd("Colorscheme", {
  pattern = "*hue",
  callback = function()
    local set_hl = function(name, data) vim.api.nvim_set_hl(0, name, data) end
    set_hl("MiniStatuslineModeNormal", { link = "MiniStatuslineFilename" })
  end,
})
