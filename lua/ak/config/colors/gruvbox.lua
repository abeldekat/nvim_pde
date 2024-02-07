--          ╭─────────────────────────────────────────────────────────╮
--          │              gruvbox has no lualine theme               │
--          │         lualine itself provides a gruvbox theme         │
--          │            mini.statusline is not supported             │
--          ╰─────────────────────────────────────────────────────────╯

local Utils = require("ak.util")

local prefer_light = require("ak.color").prefer_light
vim.o.background = prefer_light and "light" or "dark"

Utils.color.add_toggle("gruvbox", {
  name = "gruvbox",
  -- stylua: ignore
  flavours = {
    { "dark", "soft" }, { "dark", "" }, { "dark", "hard" },
    { "light", "soft" }, { "light", "" }, { "light", "hard" },
  },
  toggle = function(flavour)
    vim.o.background = flavour[1]
    require("gruvbox").setup({ contrast = flavour[2] })
    vim.cmd.colorscheme("gruvbox")
  end,
})

vim.api.nvim_create_autocmd("Colorscheme", {
  pattern = "gruvbox",
  callback = function()
    local set_default_hl = function(name, data)
      data.default = true
      vim.api.nvim_set_hl(0, name, data)
    end
    -- colors taken from lualine theme, normal c:
    local fg = prefer_light and "#7c6f64" or "#a89984"
    local bg = prefer_light and "#ebdbb2" or "#3c3836"
    set_default_hl("MiniStatuslineModeNormal", { fg = fg, bg = bg })
    set_default_hl("MiniStatuslineDevinfo", { fg = fg, bg = bg })
  end,
})

local opts = { contrast = "soft", italic = { strings = false } }
require("gruvbox").setup(opts)
