--          ╭─────────────────────────────────────────────────────────╮
--          │        gruvbox-material supports mini.statusline        │
--          ╰─────────────────────────────────────────────────────────╯

local Utils = require("ak.util")
local name = "gruvbox-material"
Utils.color.add_toggle("*material", {
  name = name,
  -- stylua: ignore
  flavours = {
    { "dark", "soft" }, { "dark", "medium" }, { "dark", "hard" },
    { "light", "soft" }, { "light", "medium" }, { "light", "hard" },
  },
  toggle = function(flavour)
    vim.o.background = flavour[1]
    vim.g.gruvbox_material_background = flavour[2]
    vim.cmd.colorscheme(name)
  end,
})

vim.api.nvim_create_autocmd("Colorscheme", {
  pattern = "gruvbox-material",
  callback = function()
    vim.cmd("highlight! link MiniStatuslineModeNormal MiniStatuslineDevinfo")
  end,
})

local prefer_light = require("ak.color").prefer_light
vim.g.gruvbox_material_foreground = "material" -- "mix", "original"
vim.g.gruvbox_material_better_performance = 1
vim.g.gruvbox_material_background = "soft"
vim.g.gruvbox_material_foreground = "material"
vim.o.background = prefer_light and "light" or "dark"
