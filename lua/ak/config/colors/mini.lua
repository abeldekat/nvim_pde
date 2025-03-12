-- NOTE: The "hues" are also very nice as light theme!

local Utils = require("ak.util")
local prefer_light = require("ak.color").prefer_light
vim.o.background = prefer_light and "light" or "dark"

local hi = function(name, data) vim.api.nvim_set_hl(0, name, data) end

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
    local p = MiniBase16.config.palette
    if p == nil then return end

    -- Is a link to DiagnosticFloatingHint, change to bold orange
    hi("MiniPickMatchRanges", { fg = "orange", bold = true })
    -- Area for messages and cmdline, change p.base05
    hi("MsgArea", { fg = p.base03 })
  end,
})

--          ╭─────────────────────────────────────────────────────────╮
--          │                          hues                           │
--          ╰─────────────────────────────────────────────────────────╯
Utils.color.add_toggle("*hue", { -- toggle randoms with leader h
  name = "mini_hues",
  -- In order to have a different random: `:colo randomhue`
  flavours = { "autumnhue", "greyhue", "springhue", "summerhue", "randomhue", "winterhue" },
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

    -- Is a link to DiagnosticFloatingHint, change to bold orange:
    hi("MiniPickMatchRanges", { fg = p.orange, bold = true })
    -- Area for messages and cmdline, changed from Normal to Comment.fg
    hi("MsgArea", { fg = p.fg_mid2 })
  end,
})
