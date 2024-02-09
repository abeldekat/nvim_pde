--          ╭─────────────────────────────────────────────────────────╮
--          │             mini.statusline: not supported              │
--          │     a lualine theme is included in the lualine repo     │
--          ╰─────────────────────────────────────────────────────────╯

local Utils = require("ak.util")
local prefer_light = require("ak.color").prefer_light

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
    local set_hl = function(name, data)
      vim.api.nvim_set_hl(0, name, data)
    end
    -- colors taken from lualine theme, normal c:
    local fg = prefer_light and "#586e75" or "#93a1a1"
    local bg = prefer_light and "#eee8d5" or "#073642"
    set_hl("MiniStatuslineModeNormal", { fg = fg, bg = bg })
    set_hl("MiniStatuslineFilename", { fg = fg, bg = bg })
  end,
})

vim.o.background = prefer_light and "light" or "dark"
