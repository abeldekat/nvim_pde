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
    local set_hl = function(name, data)
      vim.api.nvim_set_hl(0, name, data)
    end
    -- colors taken from lualine theme, normal c:
    local fg = c.nano_foreground_color
    local bg = c.nano_subtle_color
    set_hl("MiniStatuslineModeNormal", { fg = fg, bg = bg })
    set_hl("MiniStatuslineFilename", { fg = fg, bg = bg })
    set_hl("MiniStatuslineModeInsert", { fg = c.bg, bg = c.nano_popout_color })
    set_hl("MiniStatuslineModeReplace", { fg = c.bg, bg = c.nano_critical_color })
    set_hl("MiniStatuslineModeVisual", { fg = c.bg, bg = c.nano_salient_color })
    -- added
    set_hl("MiniStatuslineModeCommand", { fg = c.bg, bg = c.nano_critical_color })
    set_hl("MiniStatuslineModeOther", { fg = c.bg, bg = c.nano_critical_color })
  end,
})
