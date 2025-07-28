local add_toggle = require("akshared.color_toggle").add
local prefer_light = require("ak.color").prefer_light
vim.o.background = prefer_light and "light" or "dark"

local hi = function(name, data) vim.api.nvim_set_hl(0, name, data) end

--          ╭─────────────────────────────────────────────────────────╮
--          │                         base16                          │
--          ╰─────────────────────────────────────────────────────────╯
add_toggle({ "minischeme", "minicyan" }, {
  name = "mini_base16",
  flavours = { "minischeme", "minicyan" },
})

vim.api.nvim_create_autocmd("ColorScheme", {
  pattern = { "minischeme", "minicyan" },
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
add_toggle({ "miniwinter", "minispring", "minisummer", "miniautumn" }, {
  name = "mini_seasons",
  -- In order to have a different random: `:colo randomhue`
  flavours = { "miniwinter", "minispring", "minisummer", "miniautumn" },
})

add_toggle("randomhue", { -- toggle randoms with leader h
  name = "mini_hue",
  -- In order to have a different random: `:colo randomhue`
  flavours = { "randomhue" },
})

local Hues = require("mini.hues") -- "capture" the palette on hues.setup
vim.api.nvim_create_autocmd("ColorScheme", {
  pattern = { "randomhue", "miniwinter", "minispring", "minisummer", "miniautumn" },
  callback = function()
    local p = Hues.get_palette()

    hi("MiniJump2dSpot", { fg = p.orange, bg = nil, bold = true, nocombine = true }) -- yellow
    hi("MiniJump2dSpotAhead", { link = "MiniJump2dSpot" })
    hi("MiniJump2dSpotUnique", { link = "MiniJump2dSpot" })

    -- Is a link to DiagnosticFloatingHint, change to bold orange:
    hi("MiniPickMatchRanges", { fg = p.orange, bold = true })
    -- Area for messages and cmdline, changed from Normal to Comment.fg
    hi("MsgArea", { fg = p.fg_mid2 })
  end,
})
