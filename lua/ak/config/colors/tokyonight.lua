-- Not actively used...
-- Last commit downloaded: 057ef5d260c1931f1dffd0f052c685dcd14100a3
-- Add to colors.txt: tokyonight
local Utils = require("ak.util")
local prefer_light = require("ak.color").prefer_light

Utils.color.add_toggle("tokyonight*", {
  name = "tokyonight",
  flavours = { "tokyonight-storm", "tokyonight-moon", "tokyonight-night", "tokyonight-day" },
})

-- These groups from tokyonight.groups.init are always included!
-- local groups = { base = true, kinds = true, semantic_tokens = true, treesitter = true }
local plugins = {
  all = false, -- the default is true when not using lazy.nvim
  auto = false, -- only supported for lazy.nvim
  --
  ["blink_cmp"] = true,
  ["fzf"] = true, -- fzf-lua on demand...
  ["headlines"] = true,
  ["leap"] = true,
  ["mini_animate"] = true,
  ["mini_clue"] = true,
  -- ["mini_completion"] = false,
  ["mini_cursorword"] = true,
  ["mini_deps"] = true,
  ["mini_diff"] = true,
  ["mini_files"] = true,
  ["mini_hipatterns"] = true,
  ["mini_icons"] = true,
  ["mini_indentscope"] = true,
  ["mini_notify"] = true,
  ["mini_operators"] = true,
  ["mini_pick"] = true,
  ["mini_starter"] = true,
  ["mini_statusline"] = true,
  ["mini_surround"] = true,
  -- ["mini_test"] = false,
  -- ["mini_trailspace"] = false,
  ["neotest"] = true,
  ["cmp"] = true,
  ["dap"] = true,
  ["treesitter-context"] = true,
}

local opts = {
  dim_inactive = true,
  plugins = plugins,
  on_highlights = function(hl, c)
    -- Careful: Do not use the same table instance twice!
    hl.MsgArea = { fg = c.comment } -- fg_dark: -- Area for messages and cmdline
  end,
  style = prefer_light and "day" or "moon",
}

require("tokyonight").setup(opts)
