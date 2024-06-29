local Utils = require("ak.util")
local prefer_light = require("ak.color").prefer_light
vim.o.background = prefer_light and "light" or "dark"

Utils.color.add_toggle("mini*", {
  name = "mini_base16",
  flavours = { "minischeme", "minicyan" },
})
Utils.color.add_toggle("*hue", { -- toggle randoms with leader h
  name = "mini_hues",
  flavours = { "randomhue" },
})

vim.api.nvim_create_autocmd("Colorscheme", {
  pattern = { "mini*", "*hue" },
  callback = function()
    local set_hl = function(name, data) vim.api.nvim_set_hl(0, name, data) end
    set_hl("MiniStatuslineModeNormal", { link = "MiniStatuslineFilename" })
    set_hl("MiniPickMatchRanges", { fg = "orange", bold = true }) -- link='DiagnosticFloatingHint' -> { fg=p.cyan,   bg=p.bg_edge })

    local fg_msg_area = vim.api.nvim_get_hl(0, { name = "Comment" }).fg
    set_hl("MsgArea", { fg = fg_msg_area }) -- Area for messages and cmdline
  end,
})
