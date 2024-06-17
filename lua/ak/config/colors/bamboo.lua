--          ╭─────────────────────────────────────────────────────────╮
--          │               mini.statusline: supported                │
--          ╰─────────────────────────────────────────────────────────╯

local prefer_light = require("ak.color").prefer_light
vim.o.background = prefer_light and "light" or "dark"

local function highlights()
  -- fg color of MiniStatuslineFilename is too dimmed compared to lualine_c
  return {
    MiniStatuslineModeNormal = { fg = "$light_grey", bg = "$bg1" }, -- left and right, dynamic
    MiniStatuslineFilename = { fg = "$light_grey", bg = "$bg1" }, -- left and right, dynamic

    MiniHipatternsFixme = { fg = "$bg1", bg = "$red", fmt = "bold" },
    MiniHipatternsHack = { fg = "$bg1", bg = "$yellow", fmt = "bold" },
    MiniHipatternsTodo = { fg = "$bg1", bg = "$cyan", fmt = "bold" },
    MiniHipatternsNote = { fg = "$bg1", bg = "$purple", fmt = "bold" },
    MsgArea = { fg = "$grey" }, -- Area for messages and cmdline
  }
end

require("bamboo").setup({
  style = "vulgaris",
  toggle_style_key = "<leader>h",
  dim_inactive = true,
  highlights = highlights(),
})
