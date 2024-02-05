--          ╭─────────────────────────────────────────────────────────╮
--          │                      Experimental                       │
--          ╰─────────────────────────────────────────────────────────╯

local CTRL_S = vim.api.nvim_replace_termcodes("<C-S>", true, true, true)
local CTRL_V = vim.api.nvim_replace_termcodes("<C-V>", true, true, true)

local modes = setmetatable({
  ["n"] = { long = "Normal", short = "N", hl = "MiniStatuslineModeNormal" },
  ["v"] = { long = "Visual", short = "V", hl = "MiniStatuslineModeVisual" },
  ["V"] = { long = "V-Line", short = "V-L", hl = "MiniStatuslineModeVisual" },
  [CTRL_V] = { long = "V-Block", short = "V-B", hl = "MiniStatuslineModeVisual" },
  ["s"] = { long = "Select", short = "S", hl = "MiniStatuslineModeVisual" },
  ["S"] = { long = "S-Line", short = "S-L", hl = "MiniStatuslineModeVisual" },
  [CTRL_S] = { long = "S-Block", short = "S-B", hl = "MiniStatuslineModeVisual" },
  ["i"] = { long = "Insert", short = "I", hl = "MiniStatuslineModeInsert" },
  ["R"] = { long = "Replace", short = "R", hl = "MiniStatuslineModeReplace" },
  ["c"] = { long = "Command", short = "C", hl = "MiniStatuslineModeCommand" },
  ["r"] = { long = "Prompt", short = "P", hl = "MiniStatuslineModeOther" },
  ["!"] = { long = "Shell", short = "Sh", hl = "MiniStatuslineModeOther" },
  ["t"] = { long = "Terminal", short = "T", hl = "MiniStatuslineModeOther" },
}, {
  -- By default return 'Unknown' but this shouldn't be needed
  __index = function()
    return { long = "Unknown", short = "U", hl = "%#MiniStatuslineModeOther#" }
  end,
})

---@return ... Section string and mode's highlight group.
local function section_mode(args)
  local MiniStatusline = require("mini.statusline")
  local mode_info = modes[vim.fn.mode()]

  local mode = MiniStatusline.is_truncated(args.trunc_width) and mode_info.short or mode_info.long

  return mode, mode_info.hl
end

local function active()
  local MiniStatusline = require("mini.statusline")
  local mode, mode_hl = section_mode({ trunc_width = 120 })
  local git = MiniStatusline.section_git({ trunc_width = 75 })
  local diagnostics = MiniStatusline.section_diagnostics({ trunc_width = 75 })
  local filename = MiniStatusline.section_filename({ trunc_width = 140 })
  local fileinfo = MiniStatusline.section_fileinfo({ trunc_width = 120 })
  local location = MiniStatusline.section_location({ trunc_width = 75 })
  local search = MiniStatusline.section_searchcount({ trunc_width = 75 })

  return MiniStatusline.combine_groups({
    { hl = mode_hl, strings = { mode } },
    { hl = "MiniStatuslineInactive", strings = { git, diagnostics } },
    "%<", -- Mark general truncate point
    { hl = "MiniStatuslineInactive", strings = { filename } },
    "%=", -- End left alignment
    { hl = "MiniStatuslineInactive", strings = { fileinfo } },
    { hl = mode_hl, strings = { search, location } },
  })
end

require("mini.statusline").setup({
  use_icons = false,
  set_vim_settings = false,
  content = {
    active = active,
  },
})
