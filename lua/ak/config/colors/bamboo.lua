--          ╭─────────────────────────────────────────────────────────╮
--          │             bamboo supports mini.statusline             │
--          ╰─────────────────────────────────────────────────────────╯

local prefer_light = require("ak.color").prefer_light
vim.o.background = prefer_light and "light" or "dark"

local function highlights()
  local normal_lualine_c = { fg = "$fg", bg = "$bg1" }
  return {
    MiniStatuslineModeNormal = normal_lualine_c, -- left and right, dynamic
    MiniStatuslineDevinfo = normal_lualine_c, -- left and right, dynamic
  }
end

require("bamboo").setup({
  style = "vulgaris",
  toggle_style_key = "<leader>a",
  dim_inactive = true,
  highlights = highlights(),
})
