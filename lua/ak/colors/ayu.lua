local prefer_light = require('ak.color').prefer_light
vim.o.background = prefer_light and 'light' or 'dark'

local info = {
  name = 'ayu',
  variants = { 'ayu-mirage', 'ayu-dark', 'ayu-light' },
}
_G.Config.add_theme_info('ayu*', info, 'Ayu variants')

require('ayu').setup({
  mirage = true,
  terminal = true,
  overrides = function() -- code fragments copied from nvim @pkazmier, 00_ayu.lua
    local c = require('ayu.colors')
      -- stylua: ignore
    return {
      CursorLineNr                   = { fg = c.accent, bg = c.bg, bold = true },
      FloatTitle                     = { fg = c.tag, bold = true },
      LineNr                         = { fg = c.guide_active },

      -- Now that 'pumborder' exists, use same styling for other floats
      Pmenu                          = { fg = c.fg,           bg = c.bg },
      PmenuBorder                    = { fg = c.comment,      bg = c.bg },
      PmenuMatch                     = { fg = c.regexp,       bold = true },
      PmenuSel                       = { bg = c.selection_bg, reverse = false, bold = true },

      -- Use reverse text for diagnostics
      DiagnosticVirtualTextError     = { bg = c.error,   fg = c.line, italic = true },
      DiagnosticVirtualTextWarn      = { bg = c.keyword, fg = c.line, italic = true },
      DiagnosticVirtualTextInfo      = { bg = c.tag,     fg = c.line, italic = true },
      DiagnosticVirtualTextHint      = { bg = c.regexp,  fg = c.line, italic = true },

      -- Bold current line in MiniFiles
      MiniFilesCursorLine            = { fg = nil,        bg = c.selection_bg, bold = true },
      MiniFilesTitle                 = { fg = c.tag,      bg = c.panel_bg,     bold = false },
      MiniFilesTitleFocused          = { fg = c.tag,      bg = c.panel_bg,     bold = true },

      -- Bold matches and current line in MiniPick
      MiniPickMatchCurrent           = { fg = nil,      bg = c.selection_bg,  bold = true },
      MiniPickMatchMarked            = { fg = nil,      bg = c.gutter_normal, bold = true },
      MiniPickMatchRanges            = { fg = c.regexp, bold = true },
      MiniPickPrompt                 = { fg = c.fg, bold = true },
      MiniPickPromptPrefix           = { fg = c.tag,    bold = true },

      -- Dim inactive MiniStarter elements
      MiniStarterInactive            = { link = "MiniJump2dDim" },
      MiniStarterSection             = { fg = c.keyword, bold = true },
      MiniStarterHeader              = { fg = c.tag,     bold = true },

      MiniStatuslineFilename         = { fg = c.fg,             bg = c.selection_inactive,  bold = true },
      MiniStatuslineDevinfo          = { fg = c.fg,             bg = c.selection_bg },
      MiniStatuslineFileinfo         = { fg = c.fg,             bg = c.selection_bg },
      StatusLine                     = { fg = c.fg,             bg = c.panel_border },
      StatusLineNC                   = { fg = c.fg,             bg = c.panel_border },

      -- Extend the context highlighting to line numbers as well
      TreesitterContext              = { bg = c.selection_inactive },
      TreesitterContextBottom        = { sp = c.panel_bg,     underline = true },
      TreesitterContextLineNumber    = { fg = c.guide_active, bg = c.selection_inactive },

      ['@markup.heading']            = { fg = c.keyword,  bold = true },
      ['@markup.heading.1']          = { fg = c.accent,   bold = true },
      ['@markup.heading.2']          = { fg = c.keyword,  bold = true },
      ['@markup.heading.3']          = { fg = c.markup,   bold = true },
      ['@markup.heading.4']          = { fg = c.entity,   bold = true },
      ['@markup.heading.5']          = { fg = c.regexp,   bold = true },
      ['@markup.heading.6']          = { fg = c.string,   bold = true },
      ['@markup.strong']             = { fg = c.keyword,  bold = true },
      ['@markup.italic']             = { fg = c.keyword,  italic = true },
      ['@markup.quote']              = { fg = c.constant, italic = true },
      ['@markup.raw']                = { fg = c.tag,      bg = c.selection_inactive },
      ['@markup.list']               = { fg = c.vcs_added },
      ['@markup.raw.block']          = { fg = c.tag },
      ['@module']                    = { fg = c.fg },
      ['@string.documentation']      = { fg = c.lsp_inlay_hint },
      ['@variable.builtin']          = { fg = c.fg },
    }
  end,
})
