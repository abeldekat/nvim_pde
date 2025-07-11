-- Not actively used...
-- Last commit downloaded: 089b60e92aa0a1c6fa76ff527837cd35b6f5ac81
-- Add to colors.txt: gruvbox

local add_toggle = require("akshared.color_toggle").add

local prefer_light = require("ak.color").prefer_light
vim.o.background = prefer_light and "light" or "dark"

add_toggle("gruvbox", {
  name = "gruvbox",
  -- stylua: ignore
  flavours = {
    { "dark", "soft" }, { "dark", "" }, { "dark", "hard" },
    { "light", "soft" }, { "light", "" }, { "light", "hard" },
  },
  toggle = function(flavour)
    vim.o.background = flavour[1]
    ---@diagnostic disable-next-line: missing-fields
    require("gruvbox").setup({ contrast = flavour[2] })
    vim.cmd.colorscheme("gruvbox")
  end,
})

vim.api.nvim_create_autocmd("Colorscheme", {
  pattern = "gruvbox",
  callback = function()
    local set_hl = function(name, data) vim.api.nvim_set_hl(0, name, data) end

    local fg_msg_area = vim.api.nvim_get_hl(0, { name = "Comment" }).fg
    set_hl("MsgArea", { fg = fg_msg_area })
  end,
})

local opts = { contrast = "soft", italic = { strings = false } }
require("gruvbox").setup(opts)
