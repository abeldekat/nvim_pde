--          ╭─────────────────────────────────────────────────────────╮
--          │               mini.statusline: supported                │
--          ╰─────────────────────────────────────────────────────────╯
local Utils = require("ak.util")

-- monokai variations
-- shusia, maia and espresso variants are modified versions of Monokai Pro
Utils.color.add_toggle("sonokai", {
  name = "sonokai",
  flavours = { "andromeda", "espresso", "atlantis", "shusia", "maia", "default" },
  toggle = function(flavour)
    vim.g.sonokai_style = flavour
    vim.cmd.colorscheme("sonokai")
  end,
})

vim.api.nvim_create_autocmd("Colorscheme", {
  pattern = "sonokai",
  callback = function()
    -- the fg color is dimmed compared to lualine_c
    vim.api.nvim_set_hl(0, "MiniStatuslineModeNormal", { link = "MiniStatuslineFilename" })
  end,
})

vim.g.sonokai_better_performance = 1
vim.g.sonokai_enable_italic = 1
vim.g.sonokai_disable_italic_comment = 1
vim.g.sonokai_dim_inactive_windows = 1
vim.g.sonokai_style = "andromeda"
