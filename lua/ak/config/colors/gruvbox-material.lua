--          ╭─────────────────────────────────────────────────────────╮
--          │               mini.statusline: supported                │
--          ╰─────────────────────────────────────────────────────────╯
local Utils = require("ak.util")
local prefer_light = require("ak.color").prefer_light
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
    vim.api.nvim_set_hl(0, "MiniStatuslineModeNormal", { link = "MiniStatuslineFilename" })
  end,
})

vim.g.gruvbox_material_foreground = "material" -- "mix", "original"
vim.g.gruvbox_material_better_performance = 1
vim.g.gruvbox_material_background = "soft"
vim.g.gruvbox_material_foreground = "material"
vim.o.background = prefer_light and "light" or "dark"
