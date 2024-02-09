--          ╭─────────────────────────────────────────────────────────╮
--          │             mini.statusline: not supported              │
--          │              gruvbox has no lualine theme               │
--          │         lualine itself provides a gruvbox theme         │
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
    local set_hl = function(name, data)
      vim.api.nvim_set_hl(0, name, data)
    end
    set_hl("MiniStatuslineInactive", { link = "StatusLineNC" })
    -- colors taken from lualine theme, normal c:
    local fg = prefer_light and "#7c6f64" or "#a89984"
    local bg = prefer_light and "#ebdbb2" or "#3c3836"
    set_hl("MiniStatuslineFilename", { fg = fg, bg = bg })
    set_hl("MiniStatuslineModeNormal", { fg = fg, bg = bg })
    --
    set_hl("MiniStatuslineModeInsert", { link = "DiffChange" })
    set_hl("MiniStatuslineModeVisual", { link = "DiffAdd" })
    set_hl("MiniStatuslineModeReplace", { link = "DiffDelete" })
    set_hl("MiniStatuslineModeCommand", { link = "DiffText" })
    set_hl("MiniStatuslineModeOther", { link = "IncSearch" })
  end,
})

local opts = { contrast = "soft", italic = { strings = false } }
require("gruvbox").setup(opts)
