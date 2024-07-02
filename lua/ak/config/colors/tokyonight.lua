--          ╭─────────────────────────────────────────────────────────╮
--          │               mini.statusline: supported                │
--          ╰─────────────────────────────────────────────────────────╯
local Utils = require("ak.util")
local prefer_light = require("ak.color").prefer_light

Utils.color.add_toggle("tokyonight*", {
  name = "tokyonight",
  flavours = { "tokyonight-storm", "tokyonight-moon", "tokyonight-night", "tokyonight-day" },
})

local plugins = {
  all = false,

  base = true,
  kinds = true,
  semantic_tokens = true,
  treesitter = true,
  ["aerial.nvim"] = true,
  ["fzf-lua"] = true,
  ["headlines.nvim"] = true,
  ["indent-blankline.nvim"] = true,
  ["leap.nvim"] = true,
  ["mini.animate"] = true,
  ["mini.clue"] = true,
  ["mini.completion"] = false,
  ["mini.cursorword"] = true,
  ["mini.deps"] = true,
  ["mini.diff"] = true,
  ["mini.files"] = true,
  ["mini.hipatterns"] = true,
  ["mini.hue"] = true,
  -- ["mini.indent"] = false,
  -- ["mini.jump"] = false,
  -- ["mini.map"] = false,
  ["mini.notify"] = true,
  ["mini.operators"] = true,
  ["mini.pick"] = true,
  ["mini.starter"] = true,
  ["mini.statusline"] = true,
  ["mini.surround"] = true,
  -- ["mini.tabline"] = false,
  -- ["mini.test"] = false,
  -- ["mini.trailspace"] = false,
  ["neotest"] = true,
  ["nvim-cmp"] = true,
  ["nvim-dap"] = true,
  ["nvim-treesitter-context"] = true,
}

local opts = {
  dim_inactive = true,
  plugins = plugins,
  on_highlights = function(hl, c)
    -- Careful: Do not use the same table instance twice!
    hl.MiniStatuslineModeNormal = { bg = c.bg_statusline, fg = c.fg_sidebar } -- left and right, dynamic
    hl.MiniStatuslineFilename = { bg = c.bg_statusline, fg = c.fg_sidebar } -- all inner groups
    hl.MsgArea = { fg = c.comment } -- fg_dark: -- Area for messages and cmdline
  end,
  -- plugins = plugins,
  style = prefer_light and "day" or "storm",
}

require("tokyonight").setup(opts)
