-- Not actively used...
-- Last commit downloaded: cddfb6e61f4c92f22b1ddce7d60e32688d700ed8
-- Add to colors.txt: solarized8_flat

--          ╭─────────────────────────────────────────────────────────╮
--          │             mini.statusline: not supported              │
--          ╰─────────────────────────────────────────────────────────╯

-- Mini.pick current line not different...

local Utils = require("ak.util")
local prefer_light = require("ak.color").prefer_light
vim.o.background = prefer_light and "light" or "dark"

Utils.color.add_toggle("solarized8*", {
  name = "solarized8",
  -- stylua: ignore
  flavours = { -- solarized8_high not used
    { "dark", "solarized8_flat" }, { "dark", "solarized8_low" }, { "dark", "solarized8" },
    { "light", "solarized8_flat" }, { "light", "solarized8_low" }, { "light", "solarized8" },
  },
  toggle = function(flavour)
    vim.o.background = flavour[1]
    vim.cmd.colorscheme(flavour[2])
  end,
})

vim.api.nvim_create_autocmd("Colorscheme", {
  pattern = "solarized8*",
  callback = function()
    local set_hl = function(name, data) vim.api.nvim_set_hl(0, name, data) end
    local fg_msg_area = vim.api.nvim_get_hl(0, { name = "Comment" }).fg
    set_hl("MsgArea", { fg = fg_msg_area }) -- Area for messages and cmdline
  end,
})
