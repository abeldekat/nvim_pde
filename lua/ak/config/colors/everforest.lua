--          ╭─────────────────────────────────────────────────────────╮
--          │               mini.statusline: supported                │
--          ╰─────────────────────────────────────────────────────────╯

local Utils = require("ak.util")
local name = "everforest"

-- lazygit colors are not always readable,  good light theme
Utils.color.add_toggle(name, {
  name = name,
  -- stylua: ignore
  flavours = {
    { "dark", "soft" }, { "dark", "medium" }, { "dark", "hard" },
    { "light", "soft" }, { "light", "medium" }, { "light", "hard" },
  },
  toggle = function(flavour)
    vim.o.background = flavour[1]
    vim.g.everforest_background = flavour[2]
    vim.cmd.colorscheme(name)
  end,
})

vim.api.nvim_create_autocmd("Colorscheme", {
  pattern = "everforest",
  callback = function()
    vim.api.nvim_set_hl(0, "MiniStatuslineModeNormal", { link = "MiniStatuslineFilename" })
  end,
})

local prefer_light = require("ak.color").prefer_light
vim.g.everforest_better_performance = 1
vim.g.everforest_enable_italic = 1
vim.g.everforest_background = "medium"
vim.o.background = prefer_light and "light" or "dark"
