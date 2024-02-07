--          ╭─────────────────────────────────────────────────────────╮
--          │                      Experimental                       │
--          ╰─────────────────────────────────────────────────────────╯

-- TODO: shorter filename, colors for gitsigns and diagnostics
-- TODO: in terminal mode, only "zsh" is shown for the filename

-- about colors:
--https://github.com/echasnovski/mini.nvim/issues/153

-- hightlighting:
-- https://github.com/echasnovski/mini.nvim/issues/337
-- use separate groups for each diagnotic

-- redrawstatus:
-- vim.cmd('redrawstatus!') will redraw it immediately.
-- vim.defer_fn(function() vim.cmd('redrawstatus!') end, 100) will schedule to redraw it after 100 milliseconds.

-- mini statusline in floating lazy.nvim ui:
-- local set_active_stl = function()
--   vim.wo.statusline = "%!v:lua.MiniStatusline.active()"
-- end
-- vim.api.nvim_create_autocmd("Filetype", { pattern = "lazy", callback = set_active_stl })

local blocked_filetypes = {
  ["dashboard"] = true,
}

local function section_diagnostics(args)
  --
end

local function active()
  -- Customize statusline content for blocked filetypes to your liking
  if blocked_filetypes[vim.bo.filetype] then
    return ""
  end

  -- Continue the function
  local MiniStatusline = require("mini.statusline")

  -- Dynamic hl
  local mode, mode_hl = MiniStatusline.section_mode({ trunc_width = 120 })
  -- hl = "MiniStatuslineDevinfo"
  local git = MiniStatusline.section_git({ trunc_width = 75, icon = "" })
  local diagnostics = MiniStatusline.section_diagnostics({ trunc_width = 75, icon = "" })
  -- hl = "MiniStatuslineFilename" --> MiniStatuslineDevinfo
  local filename = MiniStatusline.section_filename({ trunc_width = 140 })
  -- hl = "MiniStatuslineFileinfo" --> MiniStatuslineDevinfo
  local fileinfo = MiniStatusline.section_fileinfo({ trunc_width = 120 })
  -- Dynamic hl
  local location = MiniStatusline.section_location({ trunc_width = 75 })
  local search = MiniStatusline.section_searchcount({ trunc_width = 75 })

  return MiniStatusline.combine_groups({
    { hl = mode_hl, strings = { string.upper(mode) } },
    { hl = "MiniStatuslineDevinfo", strings = { git, diagnostics } },
    "%<", -- Mark general truncate point
    { hl = "MiniStatuslineDevinfo", strings = { filename } },
    "%=", -- End left alignment
    { hl = "MiniStatuslineDevinfo", strings = { fileinfo } },
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
