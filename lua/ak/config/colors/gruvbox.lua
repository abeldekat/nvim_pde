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
    local set_hl = function(name, data) vim.api.nvim_set_hl(0, name, data) end

    local fg_msg_area = vim.api.nvim_get_hl(0, { name = "Comment" }).fg
    set_hl("MsgArea", { fg = fg_msg_area })
  end,
})

local opts = { contrast = "soft", italic = { strings = false } }
require("gruvbox").setup(opts)
