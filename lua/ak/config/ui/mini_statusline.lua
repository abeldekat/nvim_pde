-- Color schemes without support: astrotheme, ayu, melange, solarized8

local AK = {} -- module using the structure of MiniStatusline
local H = {} -- helpers, copied, modified or added
local MiniStatusline = require("mini.statusline")
local Utils = require("ak.util")

AK.setup = function()
  MiniStatusline.setup({
    use_icons = true,
    set_vim_settings = false,
    content = { active = AK.active },
  })
  H.create_autocommands()
  H.create_hl() -- colored diagnostics, normal mode override
  H.set_active() -- lazy loading and missing events: still show statusline
  H.optional_dependencies() -- visitsline
end

AK.active = function() -- entrypoint
  if H.is_blocked_filetype() then return "" end

  local diag = MiniStatusline.section_diagnostics({ trunc_width = 75, signs = H.diag_signs, icon = "" })
  local diff = MiniStatusline.section_diff({ trunc_width = 75, icon = "" })
  local fileinfo = AK.section_fileinfo({ trunc_width = 120 })
  -- local filename = MiniStatusline.section_filename({ trunc_width = 140 })
  local filename = AK.section_filename() -- use automatic statusline truncation
  local git = MiniStatusline.section_git({ trunc_width = 40 })
  local location = MiniStatusline.section_location({ trunc_width = 75 })
  local lsp = MiniStatusline.section_lsp({ trunc_width = 75 })
  local macro = AK.section_macro({ trunc_width = 120 })
  local marker_data = AK.section_marker({ trunc_width = 75 })
  local mode, mode_hl = MiniStatusline.section_mode({ trunc_width = 120 })
  local search = MiniStatusline.section_searchcount({ trunc_width = 75 })
  local tabinfo = AK.section_tabinfo({ trunc_width = 75 })

  mode = string.find(mode, "N", 1, false) and "N" or mode
  diag = diag and #diag > 0 and string.gsub(diag, " ", "") or diag
  local git_and_diff = string.format("%s %s", git, diff and diff:sub(2) or "")
  lsp = lsp and #lsp > 0 and "󰓃" or "" -- speaker --   server -- 󰿘 protocl -- 󰝚 music
  return MiniStatusline.combine_groups({
    { hl = mode_hl, strings = { mode } },
    { hl = H.group_default_hl, strings = { marker_data } },
    { hl = H.group_default_hl, strings = { git_and_diff } },
    "%<", -- Mark general truncate point
    { hl = "MiniStatuslineFilename", strings = { filename } },
    "%=", -- End left alignment
    { hl = "MiniHipatternsHack", strings = { macro, tabinfo } },
    { hl = H.group_default_hl, strings = { diag } },
    { hl = H.group_default_hl, strings = { fileinfo, lsp } },
    { hl = mode_hl, strings = { search, location } },
  })
end

-- overridden: Use relative path if file is in cwd. Remove oil//
AK.section_filename = function()
  local ft = vim.bo.filetype
  local full_path = Utils.full_path_of_current_buffer()
  if not full_path or ft == "ministarter" then return "" end

  local flags = "%m%r"
  if full_path == "" then return "[No Name]" .. flags end

  local fmt = ft == "oil" and ":~" or ":~:." -- oil: always show full path
  return vim.fn.fnamemodify(full_path, fmt) .. flags
end

-- overridden: removed filesize. Optional encoding and format
AK.section_fileinfo = function(args)
  local filetype = vim.bo.filetype
  if filetype == "" then return "" end -- no filetype, no show

  -- local icon = _G.MiniIcons and _G.MiniIcons.get("filetype", filetype)
  -- filetype = icon and icon or filetype -- either show icon or text

  -- Construct output string if truncated or buffer is not normal
  if MiniStatusline.is_truncated(args.trunc_width) or vim.bo.buftype ~= "" then return filetype end

  -- Construct output string with extra file info
  local encoding_and_format = ""
  local encoding = vim.bo.fileencoding or vim.bo.encoding
  local format = vim.bo.fileformat
  if not (encoding == "utf-8" and format == "unix") then
    encoding_and_format = string.format(" %s[%s]", encoding, format)
  end

  return string.format("%s%s", filetype, encoding_and_format)
end

-- added:
AK.section_marker = function(args)
  if not H.markerline or MiniStatusline.is_truncated(args.trunc_width) then return "" end
  return H.markerline.line()
end

-- added:
AK.section_tabinfo = function(args)
  if MiniStatusline.is_truncated(args.trunc_width) then return "" end
  local tabnr = vim.api.nvim_tabpage_get_number(0)
  if tabnr == 1 then return "" end
  return string.format("t%d", tabnr)
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
-- H.group_default_hl = "MiniStatuslineFilename"
H.group_default_hl = "MiniStatuslineDevinfo"

H.diag_hls = {
  error = "DiagnosticErrorStatusline",
  warn = "DiagnosticWarnStatusline",
  info = "DiagnosticInfoStatusline",
  hint = "DiagnosticHintStatusline",
}

H.diag_signs = { -- must be at the end of a section, hl does not close
  ERROR = string.format("%%#%s#%s", H.diag_hls.error, "E"),
  WARN = string.format("%%#%s#%s", H.diag_hls.warn, "W"),
  INFO = string.format("%%#%s#%s", H.diag_hls.info, "I"),
  HINT = string.format("%%#%s#%s", H.diag_hls.hint, "H"),
}

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
  au("ColorScheme", "*", H.create_hl, "Create diagnostic highlight")
  -- slow lsp(ie marksman): the symbol only shows when moving inside the buffer:
  au("LspDetach", "*", H.set_active, "Track LSP clients")
  au("LspDetach", "*", H.set_active, "Track LSP clients")
end

-- added
H.create_hl = function()
  vim.api.nvim_set_hl(0, "MiniStatuslineModeNormal", { link = H.group_default_hl })

  -- Diagnostics:
  local fallback = vim.api.nvim_get_hl(0, { name = "StatusLine", link = false })
  local fixed_hl = vim.api.nvim_get_hl(0, { name = H.group_default_hl, link = false })
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
  local blocked_filetypes = {}
  return blocked_filetypes[vim.bo.filetype]
end

H.optional_dependencies = function() -- See ak.deps.editor
  if MiniVisits == nil then return end

  local visitsline = require("ak.config.ui.visitsline")
  visitsline.setup({
    cb = H.set_active,
    highlight_active = function(text) -- optionally hl active, instead of everything
      return string.format("%%#%s#-%s-%%#%s#", "MiniHipatternsHack", text, H.group_default_hl)
    end,
  })
  H.markerline = visitsline
end

--          ╭─────────────────────────────────────────────────────────╮
--          │                        Activate                         │
--          ╰─────────────────────────────────────────────────────────╯
-- MiniStatusline.setup({ use_icons = false, set_vim_settings = false }) -- default
AK.setup()
