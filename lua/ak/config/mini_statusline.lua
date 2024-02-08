-- TODO: shorter filename
-- TODO: in terminal mode, only "zsh" is shown for the filename

--          ╭─────────────────────────────────────────────────────────╮
--          │                          Notes                          │
--          ╰─────────────────────────────────────────────────────────╯
-- about colors:
--https://github.com/echasnovski/mini.nvim/issues/153

-- hightlighting:
-- https://github.com/echasnovski/mini.nvim/issues/337
-- use separate groups for each diagnostic

-- redrawstatus:
-- vim.cmd('redrawstatus!') will redraw it immediately.
-- vim.defer_fn(function() vim.cmd('redrawstatus!') end, 100) will schedule to redraw it after 100 milliseconds.

-- mini statusline in floating lazy.nvim ui:
-- local set_active_stl = function()
--   vim.wo.statusline = "%!v:lua.MiniStatusline.active()"
-- end
-- vim.api.nvim_create_autocmd("Filetype", { pattern = "lazy", callback = set_active_stl })

--          ╭─────────────────────────────────────────────────────────╮
--          │                    Module definition                    │
--          ╰─────────────────────────────────────────────────────────╯
local AK = {} -- module using MiniStatusline
local H = {} -- helpers, copied, modified or added

--          ╭─────────────────────────────────────────────────────────╮
--          │                      Module setup                       │
--          ╰─────────────────────────────────────────────────────────╯
AK.setup = function()
  H.create_diagnostic_hl() -- diagnostics with colors
  vim.api.nvim_create_autocmd("ColorScheme", {
    pattern = "*",
    callback = H.create_diagnostic_hl,
  }) -- recreate when changing colorscheme

  require("mini.statusline").setup({
    use_icons = false,
    set_vim_settings = false,
    content = { active = AK.active }, -- entrypoint
  })
  H.create_autocommands() -- lsp autocommands for custom lsp section
end

--          ╭─────────────────────────────────────────────────────────╮
--          │                       Entrypoint                        │
--          ╰─────────────────────────────────────────────────────────╯
AK.active = function()
  if H.is_blocked_filetype() then
    return "" -- Customize statusline content for blocked filetypes to your liking
  end
  local MiniStatusline = require("mini.statusline")

  -- Dynamic hl
  local mode, mode_hl = MiniStatusline.section_mode({ trunc_width = 120 })

  -- hl = "MiniStatuslineDevinfo"
  local git = MiniStatusline.section_git({ trunc_width = 75, icon = "" })
  local lsp = AK.section_lsp({ trunc_width = 37, icon = "" })
  local diagnostics = AK.section_diagnostics({ trunc_width = 37 })

  -- hl = "MiniStatuslineFilename" --> MiniStatuslineDevinfo
  local filename = MiniStatusline.section_filename({ trunc_width = 140 })

  -- hl = "MiniStatuslineFileinfo" --> MiniStatuslineDevinfo
  local fileinfo = AK.section_fileinfo({ trunc_width = 120 })

  -- Dynamic hl using the hl of section_mode
  local search = MiniStatusline.section_searchcount({ trunc_width = 75 })
  local location = AK.section_location({ trunc_width = 75 })

  return MiniStatusline.combine_groups({
    { hl = mode_hl, strings = { string.upper(mode) } },
    { hl = "MiniStatuslineDevinfo", strings = { git, lsp, diagnostics } },
    "%<", -- Mark general truncate point
    { hl = "MiniStatuslineDevinfo", strings = { filename } },
    "%=", -- End left alignment
    { hl = "MiniStatuslineDevinfo", strings = { fileinfo } },
    { hl = mode_hl, strings = { search, location } },
  })
end

--          ╭─────────────────────────────────────────────────────────╮
--          │                        Sections                         │
--          ╰─────────────────────────────────────────────────────────╯

-- overridden: removed lsp, added color to diagnostics
AK.section_diagnostics = function(args) -- args
  local MiniStatusline = require("mini.statusline")
  local dont_show = MiniStatusline.is_truncated(args.trunc_width) or H.isnt_normal_buffer()
  if dont_show then
    return ""
  end

  -- Construct string parts
  local counts = H.get_diagnostic_count()
  local severity, t = vim.diagnostic.severity, {}
  for _, level in ipairs(H.diagnostic_levels) do
    local n = counts[severity[level.name]] or 0
    if n > 0 then -- Add level info only if diagnostic is present
      table.insert(t, string.format(" %%#%s#%s%s", level.hl, level.sign, n))
    end
  end

  if vim.tbl_count(t) == 0 then
    return ""
  end
  return string.format("%s", table.concat(t, ""))
end

-- added:
AK.section_lsp = function(args)
  local MiniStatusline = require("mini.statusline")
  _G.n_attached_lsp = H.n_attached_lsp

  local dont_show = MiniStatusline.is_truncated(args.trunc_width) or H.isnt_normal_buffer() or H.has_no_lsp_attached()
  if dont_show then
    return ""
  end

  local icon = args.icon or "LSP"
  return string.format("%s", icon)
end

-- overridden: removed filesize
AK.section_fileinfo = function(args)
  local MiniStatusline = require("mini.statusline")
  local filetype = vim.bo.filetype

  -- Don't show anything if can't detect file type or not inside a "normal
  -- buffer"
  if (filetype == "") or H.isnt_normal_buffer() then
    return ""
  end

  -- Construct output string if truncated
  if MiniStatusline.is_truncated(args.trunc_width) then
    return filetype
  end

  -- Construct output string with extra file info
  local encoding = vim.bo.fileencoding or vim.bo.encoding
  local format = vim.bo.fileformat
  return string.format("%s %s[%s]", filetype, encoding, format)
end

-- overridden: changed delimiters
AK.section_location = function(args)
  local MiniStatusline = require("mini.statusline")

  -- Use virtual column number to allow update when past last column
  if MiniStatusline.is_truncated(args.trunc_width) then
    return "%l│%2v"
  end

  -- Use `virtcol()` to correctly handle multi-byte characters
  return '%l|%L %2v|%-2{virtcol("$") - 1}'
end

--          ╭─────────────────────────────────────────────────────────╮
--          │                       Helper data                       │
--          ╰─────────────────────────────────────────────────────────╯
-- overridden: added hl
H.diagnostic_levels = {
  { name = "ERROR", sign = "E", hl = "DiagnosticErrorStatusline" },
  { name = "WARN", sign = "W", hl = "DiagnosticWarnStatusline" },
  { name = "INFO", sign = "I", hl = "DiagnosticInfoStatusline" },
  { name = "HINT", sign = "H", hl = "DiagnosticHintStatusline" },
}

-- copied
H.n_attached_lsp = {} -- Count of attached LSP clients per buffer id

--          ╭─────────────────────────────────────────────────────────╮
--          │                  Helper functionality                   │
--          ╰─────────────────────────────────────────────────────────╯
-- added: Remove the lsp autocommands and recreate them to be used here.
H.create_autocommands = function()
  local to_remove = vim.api.nvim_get_autocmds({
    group = "MiniStatusline",
    event = { "LspAttach", "LspDetach" },
  })
  for _, autocmd in ipairs(to_remove) do
    vim.api.nvim_del_autocmd(autocmd.id)
  end

  local make_track_lsp = function(increment)
    return function(data)
      H.n_attached_lsp[data.buf] = (H.n_attached_lsp[data.buf] or 0) + increment
    end
  end
  local augroup = vim.api.nvim_create_augroup("MiniStatuslineAk", {})

  local au = function(event, pattern, callback, desc)
    vim.api.nvim_create_autocmd(event, { group = augroup, pattern = pattern, callback = callback, desc = desc })
  end
  au("LspAttach", "*", make_track_lsp(1), "Track LSP clients")
  au("LspDetach", "*", make_track_lsp(-1), "Track LSP clients")
end

-- added
H.create_diagnostic_hl = function()
  local devinfo = vim.api.nvim_get_hl(0, { name = "MiniStatuslineDevinfo" })
  local bg = devinfo.bg

  local de = vim.api.nvim_get_hl(0, { name = "DiagnosticError" })
  local dw = vim.api.nvim_get_hl(0, { name = "DiagnosticWarn" })
  local di = vim.api.nvim_get_hl(0, { name = "DiagnosticInfo" })
  local dh = vim.api.nvim_get_hl(0, { name = "DiagnosticHint" })

  vim.api.nvim_set_hl(0, "DiagnosticErrorStatusline", { bg = bg, fg = de.fg })
  vim.api.nvim_set_hl(0, "DiagnosticWarnStatusline", { bg = bg, fg = dw.fg })
  vim.api.nvim_set_hl(0, "DiagnosticInfoStatusline", { bg = bg, fg = di.fg })
  vim.api.nvim_set_hl(0, "DiagnosticHintStatusline", { bg = bg, fg = dh.fg })
end

--          ╭─────────────────────────────────────────────────────────╮
--          │                    Helper utilities                     │
--          ╰─────────────────────────────────────────────────────────╯
-- copied
H.isnt_normal_buffer = function()
  -- For more information see ":h buftype"
  return vim.bo.buftype ~= ""
end

-- added
H.is_blocked_filetype = function()
  local blocked_filetypes = {
    ["dashboard"] = true,
  }
  return blocked_filetypes[vim.bo.filetype]
end

-- copied
H.get_diagnostic_count = function()
  local res = {}
  for _, d in ipairs(vim.diagnostic.get(0)) do
    res[d.severity] = (res[d.severity] or 0) + 1
  end
  return res
end

-- copied
H.has_no_lsp_attached = function()
  return (H.n_attached_lsp[vim.api.nvim_get_current_buf()] or 0) == 0
end

-- copied
if vim.fn.has("nvim-0.10") == 1 then
  H.get_diagnostic_count = function()
    return vim.diagnostic.count(0)
  end
end

--          ╭─────────────────────────────────────────────────────────╮
--          │                        Activate                         │
--          ╰─────────────────────────────────────────────────────────╯
AK.setup()
