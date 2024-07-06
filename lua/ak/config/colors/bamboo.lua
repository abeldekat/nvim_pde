--          ╭─────────────────────────────────────────────────────────╮
--          │               mini.statusline: supported                │
--          ╰─────────────────────────────────────────────────────────╯

local prefer_light = require("ak.color").prefer_light
vim.o.background = prefer_light and "light" or "dark"

local function highlights()
  return {
    MiniStatuslineModeNormal = { link = "MiniStatuslineFilename" },
    MsgArea = { fg = "$grey" }, -- Area for messages and cmdline
  }
end

require("bamboo").setup({
  style = "vulgaris",
  toggle_style_key = "<leader>h",
  dim_inactive = true,
  highlights = highlights(),
})
