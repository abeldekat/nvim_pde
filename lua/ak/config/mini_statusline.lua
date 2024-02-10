--          ╭─────────────────────────────────────────────────────────╮
--          │                          Notes                          │
--          ╰─────────────────────────────────────────────────────────╯
-- Lualine:
-- The intent of MiniStatuslineFilename is the same as lualine_c

-- hightlighting:
-- https://github.com/echasnovski/mini.nvim/issues/337
-- use separate groups for each diagnostic

-- mini statusline in floating lazy.nvim ui:
-- local set_active_stl = function()
--   vim.wo.statusline = "%!v:lua.MiniStatusline.active()"
-- end
-- vim.api.nvim_create_autocmd("Filetype", { pattern = "lazy", callback = set_active_stl })

--          ╭─────────────────────────────────────────────────────────╮
--          │                    Module definition                    │
--          ╰─────────────────────────────────────────────────────────╯
local AK = {} -- module using the structure of MiniStatusline
local H = {} -- helpers, copied, modified or added

--          ╭─────────────────────────────────────────────────────────╮
--          │                      Module setup                       │
--          ╰─────────────────────────────────────────────────────────╯
AK.setup = function()
  -- copied
  if vim.fn.has("nvim-0.10") == 1 then
    H.get_diagnostic_count = function() return vim.diagnostic.count(0) end --
  end

  H.create_diagnostic_hl() -- added diagnostics with colors
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
  H.set_active() -- lazy loading, missing events, still show statusline
end

--          ╭─────────────────────────────────────────────────────────╮
--          │                       Entrypoint                        │
--          ╰─────────────────────────────────────────────────────────╯
AK.active = function()
  -- Customize statusline content for blocked filetypes to your liking
  if H.is_blocked_filetype() then return "" end

  local MiniStatusline = require("mini.statusline")

  -- 1
  local mode, mode_hl = MiniStatusline.section_mode({ trunc_width = 120 })
  -- 2
  local git = MiniStatusline.section_git({ trunc_width = 75, icon = "" })
  local lsp = AK.section_lsp({ trunc_width = 75, icon = "" })
  local diagnostics = AK.section_diagnostics({ trunc_width = 75 })
  -- 3
  local filename = AK.section_filename({ trunc_width = 140 })
  -- 4 added:
  local macro = AK.section_macro({ trunc_width = 120 })
  -- 5
  local fileinfo = AK.section_fileinfo({ trunc_width = 120 })
  -- 6
  local search = MiniStatusline.section_searchcount({ trunc_width = 75 })
  local location = AK.section_location({ trunc_width = 75 })

  return MiniStatusline.combine_groups({
    { hl = mode_hl, strings = { string.upper(mode) } }, -- Dynamic mode_hl
    { hl = H.fixed_hl, strings = { git, lsp, diagnostics } }, -- "..Devinfo"
    "%<", -- Mark general truncate point
    { hl = H.fixed_hl, strings = { filename } }, -- "..Filename"
    "%=", -- End left alignment
    { hl = "MiniStatuslineModeCommand", strings = { macro } }, -- "..ModeCommand", added
    { hl = H.fixed_hl, strings = { fileinfo } }, -- "..Fileinfo"
    { hl = mode_hl, strings = { search, location } }, -- Dynamic mode_hl
  })
end

--          ╭─────────────────────────────────────────────────────────╮
--          │                        Sections                         │
--          ╰─────────────────────────────────────────────────────────╯

-- added: removed from section_diagnostics
AK.section_lsp = function(args)
  local MiniStatusline = require("mini.statusline")
  _G.n_attached_lsp = H.n_attached_lsp

  local dont_show = MiniStatusline.is_truncated(args.trunc_width) or H.isnt_normal_buffer() or H.has_no_lsp_attached()
  if dont_show then return "" end

  local icon = args.icon or "LSP"
  return string.format("%s", icon)
end

-- overridden: removed lsp, added color to diagnostics
AK.section_diagnostics = function(args) -- args
  local MiniStatusline = require("mini.statusline")
  local dont_show = MiniStatusline.is_truncated(args.trunc_width) or H.isnt_normal_buffer()
  if dont_show then return "" end

  -- Construct string parts
  local counts = H.get_diagnostic_count()
  local severity, t = vim.diagnostic.severity, {}
  for _, level in ipairs(H.diagnostic_levels) do
    local n = counts[severity[level.name]] or 0
    if n > 0 then -- Add level info only if diagnostic is present
      table.insert(t, string.format(" %%#%s#%s%s", level.hl, level.sign, n))
    end
  end

  if vim.tbl_count(t) == 0 then return "" end
  return string.format("%s", table.concat(t, ""))
end

-- overridden: in terminal, use full name. Use relative path if file is in cwd
AK.section_filename = function(args)
  local function is_in_cwd()
    local cwd = vim.fn.getcwd()
    local full_path = vim.fn.expand("%:p")
    local separator = package.config:sub(1, 1)
    return full_path:find(cwd .. separator, 1, true) == 1
  end
  local MiniStatusline = require("mini.statusline")
  local full_fmt = "%F%m%r" -- modified and readonly flags
  local relative_fmt = "%f%m%r" -- modified and readonly flags

  if MiniStatusline.is_truncated(args.trunc_width) then
    return relative_fmt
  else
    return is_in_cwd() and relative_fmt or full_fmt
  end
end

-- added: show when recording a macro
AK.section_macro = function(args)
  local MiniStatusline = require("mini.statusline")
  if MiniStatusline.is_truncated(args.trunc_width) then return "" end

  local reg = vim.fn.reg_recording()
  return reg == "" and reg or "recording @" .. reg
end

-- overridden: removed filesize
AK.section_fileinfo = function(args)
  local MiniStatusline = require("mini.statusline")
  local filetype = vim.bo.filetype

  -- Only show when filetype is detected in normal buffer
  if (filetype == "") or H.isnt_normal_buffer() then return "" end

  -- Construct output string if truncated
  if MiniStatusline.is_truncated(args.trunc_width) then return filetype end

  -- Construct output string with extra file info
  local encoding = vim.bo.fileencoding or vim.bo.encoding
  local format = vim.bo.fileformat
  return string.format("%s %s[%s]", filetype, encoding, format)
end

-- overridden: changed delimiters
AK.section_location = function(args)
  local MiniStatusline = require("mini.statusline")

  -- Use virtual column number to allow update when past last column
  if MiniStatusline.is_truncated(args.trunc_width) then return "%l│%2v" end

  -- Use `virtcol()` to correctly handle multi-byte characters
  return '%l|%L %2v|%-2{virtcol("$") - 1}'
end

--          ╭─────────────────────────────────────────────────────────╮
--          │                       Helper data                       │
--          ╰─────────────────────────────────────────────────────────╯
-- added:
H.diagnostic_hls = {
  error = "DiagnosticErrorStatusline",
  warn = "DiagnosticWarnStatusline",
  info = "DiagnosticInfoStatusline",
  hint = "DiagnosticHintStatusline",
}

-- added. Colors only appear:
--   for diagnostics
--   in any mode except normal mode
--   when recording a macro
H.fixed_hl = "MiniStatuslineFilename"

-- overridden: added hl
H.diagnostic_levels = {
  { name = "ERROR", sign = "E", hl = H.diagnostic_hls.error },
  { name = "WARN", sign = "W", hl = H.diagnostic_hls.warn },
  { name = "INFO", sign = "I", hl = H.diagnostic_hls.info },
  { name = "HINT", sign = "H", hl = H.diagnostic_hls.hint },
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
      if increment > 0 then
        -- slow lsp(ie marksman): the symbol only shows when moving inside the buffer:
        H.set_active()
      end
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
  local fallback = vim.api.nvim_get_hl(0, { name = "StatusLine" })
  local fixed_hl = vim.api.nvim_get_hl(0, { name = H.fixed_hl })
  local bg = fixed_hl and fixed_hl.bg or fallback.bg
  local function fg(name)
    local hl = vim.api.nvim_get_hl(0, { name = name })
    if hl.link then -- ie gruvbox
      hl = vim.api.nvim_get_hl(0, { name = hl.link })
    end
    return hl and hl.fg or fallback.fg
  end

  vim.api.nvim_set_hl(0, H.diagnostic_hls.error, { bg = bg, fg = fg("DiagnosticError") })
  vim.api.nvim_set_hl(0, H.diagnostic_hls.warn, { bg = bg, fg = fg("DiagnosticWarn") })
  vim.api.nvim_set_hl(0, H.diagnostic_hls.info, { bg = bg, fg = fg("DiagnosticInfo") })
  vim.api.nvim_set_hl(0, H.diagnostic_hls.hint, { bg = bg, fg = fg("DiagnosticHint") })
end

--          ╭─────────────────────────────────────────────────────────╮
--          │                    Helper utilities                     │
--          ╰─────────────────────────────────────────────────────────╯
-- added, manually activate, lsp can be slow:
H.set_active = function() vim.wo.statusline = "%!v:lua.MiniStatusline.active()" end

-- added
H.is_blocked_filetype = function()
  local blocked_filetypes = { ["dashboard"] = true }
  return blocked_filetypes[vim.bo.filetype]
end

-- copied
H.isnt_normal_buffer = function()
  -- For more information see ":h buftype"
  return vim.bo.buftype ~= ""
end

-- copied
H.has_no_lsp_attached = function() return (H.n_attached_lsp[vim.api.nvim_get_current_buf()] or 0) == 0 end

-- copied
H.get_diagnostic_count = function()
  local res = {}
  for _, d in ipairs(vim.diagnostic.get(0)) do
    res[d.severity] = (res[d.severity] or 0) + 1
  end
  return res
end

--          ╭─────────────────────────────────────────────────────────╮
--          │                        Activate                         │
--          ╰─────────────────────────────────────────────────────────╯
AK.setup()
