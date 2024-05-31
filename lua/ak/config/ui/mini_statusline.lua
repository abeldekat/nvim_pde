local AK = {} -- module using the structure of MiniStatusline
local H = {} -- helpers, copied, modified or added
local MiniStatusline = require("mini.statusline")

AK.setup = function()
  H.create_diagnostic_hl() -- colored diagnostics
  H.require_markerline()
  MiniStatusline.setup({
    use_icons = false,
    set_vim_settings = false,
    content = { active = AK.active }, -- entrypoint
  })
  H.create_autocommands() -- lsp autocommands for custom lsp section
  H.set_active() -- lazy loading, missing events, still show statusline
end

AK.active = function() -- entrypoint
  if H.is_blocked_filetype() then return "" end

  local diag = MiniStatusline.section_diagnostics({ trunc_width = 75, icon = "", signs = H.diag_signs })
  local diff = MiniStatusline.section_diff({ trunc_width = 75, icon = "" })
  local fileinfo = AK.section_fileinfo({ trunc_width = 120 })
  local filename = AK.section_filename({ trunc_width = 140 })
  local git = MiniStatusline.section_git({ trunc_width = 40, icon = "" })
  local location = AK.section_location({ trunc_width = 75 })
  local lsp = MiniStatusline.section_lsp({ trunc_width = 75 })
  local macro = AK.section_macro({ trunc_width = 120 })
  local marker_data = AK.section_marker({ trunc_width = 75 })
  local mode, mode_hl = MiniStatusline.section_mode({ trunc_width = 120 })
  local search = MiniStatusline.section_searchcount({ trunc_width = 75 })

  diag = diag and diag:gsub(" ", "") or ""
  diff = diff and diff:sub(2) or "" -- remove first space
  lsp = lsp and #lsp > 0 and " " or ""
  return MiniStatusline.combine_groups({
    { hl = mode_hl, strings = { mode } },
    { hl = H.marker_highlight(), strings = { marker_data } },
    { hl = H.fixed_hl, strings = { git, diff } },
    { hl = H.fixed_hl, strings = { lsp, diag } },
    "%<", -- Mark general truncate point
    { hl = H.fixed_hl, strings = { filename } },
    "%=", -- End left alignment
    { hl = "MiniStatuslineModeCommand", strings = { macro } },
    { hl = H.fixed_hl, strings = { fileinfo } },
    { hl = mode_hl, strings = { search, location } },
  })
end

-- overridden: Use relative path if file is in cwd
AK.section_filename = function(args)
  local function is_in_cwd()
    local cwd = vim.fn.getcwd()
    local full_path = vim.fn.expand("%:p")
    local separator = package.config:sub(1, 1)
    return full_path:find(cwd .. separator, 1, true) == 1
  end
  local full_fmt = "%:~"
  local relative_fmt = "%:."

  local actual_fmt = is_in_cwd() and relative_fmt or full_fmt
  if MiniStatusline.is_truncated(args.trunc_width) then actual_fmt = relative_fmt end
  return vim.fn.expand(actual_fmt) .. "%m%r" -- modified and readonly
end

-- overridden: removed filesize
AK.section_fileinfo = function(args)
  local filetype = vim.bo.filetype
  -- Don't show anything if no filetype or not inside a "normal buffer"
  if filetype == "" or vim.bo.buftype ~= "" then return "" end

  -- Construct output string if truncated
  if MiniStatusline.is_truncated(args.trunc_width) then return filetype end

  -- Construct output string with extra file info
  local encoding = vim.bo.fileencoding or vim.bo.encoding
  local format = vim.bo.fileformat
  return string.format("%s %s[%s]", filetype, encoding, format)
end

-- overridden: changed delimiters
AK.section_location = function(args)
  -- Use virtual column number to allow update when past last column
  if MiniStatusline.is_truncated(args.trunc_width) then return "%l│%2v" end

  -- Use `virtcol()` to correctly handle multi-byte characters
  return '%l|%L %2v|%-2{virtcol("$") - 1}'
end

-- added:
AK.section_marker = function(args)
  if not H.markerline or MiniStatusline.is_truncated(args.trunc_width) then return "" end
  return H.markerline.line()
end

-- added: show when recording a macro
AK.section_macro = function(args)
  if MiniStatusline.is_truncated(args.trunc_width) then return "" end
  local reg = vim.fn.reg_recording()
  return reg == "" and "" or "REC @" .. reg
end

--          ╭─────────────────────────────────────────────────────────╮
--          │                       Helper data                       │
--          ╰─────────────────────────────────────────────────────────╯
-- added:
H.diag_hls = {
  error = "DiagnosticErrorStatusline",
  warn = "DiagnosticWarnStatusline",
  info = "DiagnosticInfoStatusline",
  hint = "DiagnosticHintStatusline",
}
H.diag_signs = {
  ERROR = string.format("%%#%s#%s", H.diag_hls.error, "E"),
  WARN = string.format("%%#%s#%s", H.diag_hls.warn, "W"),
  INFO = string.format("%%#%s#%s", H.diag_hls.info, "I"),
  HINT = string.format("%%#%s#%s", H.diag_hls.hint, "H"),
}

-- added. Colors appear: for diagnostics, any mode except normal, macro recording
H.fixed_hl = "MiniStatuslineFilename"

-- Supports harpoon or grapple
---@class Markerline
---@field line function
---@field is_buffer function
H.markerline = nil

--          ╭─────────────────────────────────────────────────────────╮
--          │                  Helper functionality                   │
--          ╰─────────────────────────────────────────────────────────╯
-- added:
H.create_autocommands = function()
  local augroup = vim.api.nvim_create_augroup("MiniStatuslineAk", {})
  local au = function(event, pattern, callback, desc)
    vim.api.nvim_create_autocmd(event, { group = augroup, pattern = pattern, callback = callback, desc = desc })
  end
  -- Colored diagnostics
  au("ColorScheme", "*", H.create_diagnostic_hl, "Create diagnostic highlight")
  -- slow lsp(ie marksman): the symbol only shows when moving inside the buffer:
  au("LspDetach", "*", H.set_active, "Track LSP clients")
  au("LspDetach", "*", H.set_active, "Track LSP clients")
end

-- added
H.create_diagnostic_hl = function()
  local fallback = vim.api.nvim_get_hl(0, { name = "StatusLine", link = false })
  local fixed_hl = vim.api.nvim_get_hl(0, { name = H.fixed_hl, link = false })
  local bg = fixed_hl and fixed_hl.bg or fallback.bg
  local function fg(name)
    local hl = vim.api.nvim_get_hl(0, { name = name, link = false })
    return hl and hl.fg or (hl.sp and hl.sp) or fallback.fg
  end

  vim.api.nvim_set_hl(0, H.diag_hls.error, { bg = bg, fg = fg("DiagnosticError") })
  vim.api.nvim_set_hl(0, H.diag_hls.warn, { bg = bg, fg = fg("DiagnosticWarn") })
  vim.api.nvim_set_hl(0, H.diag_hls.info, { bg = bg, fg = fg("DiagnosticInfo") })
  vim.api.nvim_set_hl(0, H.diag_hls.hint, { bg = bg, fg = fg("DiagnosticHint") })
end

--          ╭─────────────────────────────────────────────────────────╮
--          │                    Helper utilities                     │
--          ╰─────────────────────────────────────────────────────────╯
-- added, manually activate, lsp can be slow:
H.set_active = function() vim.wo.statusline = "%{%v:lua.MiniStatusline.active()%}" end

-- added
H.is_blocked_filetype = function()
  local blocked_filetypes = { ["starter"] = true }
  return blocked_filetypes[vim.bo.filetype]
end

H.require_markerline = function() -- See ak.deps.editor
  local function make(line, is_buffer) return { line = line, is_buffer = is_buffer } end
  local line

  local has, _ = pcall(require, "harpoon")
  if has then
    line = require("harpoonline")
    require("ak.config.ui.harpoonline").setup(H.set_active)
    H.markerline = make(line.format, line.is_buffer_harpooned)
  end

  has, _ = pcall(require, "grapple")
  if has then -- internal plugin
    line = require("ak.config.ui.grappleline")
    line.setup(H.set_active)
    H.markerline = make(line.line, line.is_current_buffer_tagged)
  end
end

-- added
H.marker_highlight = function() return H.markerline and H.markerline.is_buffer() and "MiniHipatternsHack" or H.fixed_hl end

--          ╭─────────────────────────────────────────────────────────╮
--          │                        Activate                         │
--          ╰─────────────────────────────────────────────────────────╯
-- MiniStatusline.setup({ use_icons = false, set_vim_settings = false }) -- default
AK.setup()
