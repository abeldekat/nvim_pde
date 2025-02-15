-- Not actively used...
-- Last commit downloaded: 0b1158c4911f4bd9d5a1e2e7669ebff893435b64
-- Add to colors.txt: nano-theme

--          ╭─────────────────────────────────────────────────────────╮
--          │             mini.statusline: not supported              │
--          ╰─────────────────────────────────────────────────────────╯
-- very few colors, solarized look
local Utils = require("ak.util")
local prefer_light = require("ak.color").prefer_light
vim.o.background = prefer_light and "light" or "dark"

Utils.color.add_toggle("nano-theme", {
  name = "nano-theme",
  flavours = { "dark", "light" },
  toggle = function(flavour)
    vim.o.background = flavour
    vim.cmd.colorscheme("nano-theme")
  end,
})

vim.api.nvim_create_autocmd("Colorscheme", {
  pattern = "nano-theme",
  callback = function()
    local c = require("nano-theme.colors").get()
    local set_hl = function(name, data) vim.api.nvim_set_hl(0, name, data) end
    set_hl("MsgArea", { fg = c.nano_faded_color }) -- Area for messages and cmdline
  end,
})
