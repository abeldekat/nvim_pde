local Utils = require("ak.util")
local prefer_light = require("ak.color").prefer_light
vim.o.background = prefer_light and "light" or "dark"

--          ╭─────────────────────────────────────────────────────────╮
--          │                         base16                          │
--          ╰─────────────────────────────────────────────────────────╯
Utils.color.add_toggle("mini*", {
  name = "mini_base16",
  flavours = { "minischeme", "minicyan" },
})
vim.api.nvim_create_autocmd("Colorscheme", {
  pattern = { "mini*" },
  callback = function()
    -- TODO: base16.config.palette
    local hi = function(name, data) vim.api.nvim_set_hl(0, name, data) end
    hi("MiniStatuslineModeNormal", { link = "MiniStatuslineFilename" })
    hi("MiniPickMatchRanges", { fg = "orange", bold = true }) -- DiagnosticFloatingHint{fg=p.cyan, bg=p.bg_edge})

    local fg_msg_area = vim.api.nvim_get_hl(0, { name = "Comment" }).fg
    hi("MsgArea", { fg = fg_msg_area }) -- Area for messages and cmdline
  end,
})

--          ╭─────────────────────────────────────────────────────────╮
--          │                          hues                           │
--          ╰─────────────────────────────────────────────────────────╯
Utils.color.add_toggle("*hue", { -- toggle randoms with leader h
  name = "mini_hues",
  flavours = { "randomhue" },
})
local Hues = require("mini.hues") -- "capture" the palette on hues.setup
local orig_make_palette = Hues.make_palette
local p = nil
---@diagnostic disable-next-line: duplicate-set-field
Hues.make_palette = function(config)
  p = orig_make_palette(config)
  return p
end
vim.api.nvim_create_autocmd("Colorscheme", {
  pattern = { "*hue" },
  callback = function()
    if p == nil then return end

    local hi = function(name, data) vim.api.nvim_set_hl(0, name, data) end
    hi("MiniStatuslineModeNormal", { link = "MiniStatuslineFilename" })
    hi("MiniPickMatchRanges", { fg = p.orange, bold = true }) -- DiagnosticFloatingHint{fg=p.cyan, bg=p.bg_edge})

    -- Links to MiniJump2dSpot by default, changed fg(fg_edge2)
    hi("MiniJump2dSpotUnique", { fg = p.orange, bg = p.bg_edge2, bold = true, nocombine = true })

    -- Area for messages and cmdline, using Comment.fg
    hi("MsgArea", { fg = p.fg_mid2 })
  end,
})
