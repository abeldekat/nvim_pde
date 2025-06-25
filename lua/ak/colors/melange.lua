local prefer_light = require("ak.color").prefer_light
vim.o.background = prefer_light and "light" or "dark"

vim.api.nvim_create_autocmd("Colorscheme", {
  pattern = "melange",
  callback = function()
    local set_hl = function(name, data) vim.api.nvim_set_hl(0, name, data) end

    -- local red = vim.api.nvim_get_hl(0, { name = "DiagnosticError" }).fg
    -- local yellow = vim.api.nvim_get_hl(0, { name = "DiagnosticWarn" }).fg
    -- local blue = vim.api.nvim_get_hl(0, { name = "DiagnosticInfo" }).fg
    -- local cyan = vim.api.nvim_get_hl(0, { name = "DiagnosticHint" }).fg

    set_hl("MiniJump2dSpot", { fg = "orange", bg = nil, bold = true, nocombine = true })
    set_hl("MiniJump2dSpotAhead", { link = "MiniJump2dSpot" })
    set_hl("MiniJump2dSpotUnique", { link = "MiniJump2dSpot" })
    set_hl("MiniPickMatchRanges", { fg = "orange", bold = true })
    set_hl("MiniPickNormal", { link = "Normal" }) -- NormalFloat

    local fg_msg_area = vim.api.nvim_get_hl(0, { name = "Comment" }).fg
    set_hl("MsgArea", { fg = fg_msg_area })
  end,
})
