-- Made with 'mini.colors' module of https://github.com/echasnovski/mini.nvim
-- Colors from gruvbuddy(colorbuddy). Gruvbuddy is much slower...
-- Removed cmp hi

if vim.g.colors_name ~= nil then vim.cmd("highlight clear") end
vim.g.colors_name = "gruvbuddy_minicolors"

-- Highlight groups
local hi = vim.api.nvim_set_hl

hi(0, "@boolean", { fg = "#de935f" })
hi(0, "@character.special", { bold = true, fg = "#cc6666" })
hi(0, "@constant", { fg = "#de935f" })
hi(0, "@function", { fg = "#f8fe7a" })
hi(0, "@function.bracket", { bg = "#111111", fg = "#e0e0e0" })
hi(0, "@function.call.lua", { fg = "#5f89ad" })
hi(0, "@ibl.indent.char.1", { fg = "#8e6fbd", nocombine = true })
hi(0, "@ibl.scope.char.1", { bg = "#111111", fg = "#282a2e", nocombine = true })
hi(0, "@ibl.scope.underline.1", { sp = "#282a2e", underline = true })
hi(0, "@ibl.whitespace.char.1", { fg = "#8e6fbd", nocombine = true })
hi(0, "@keyword", { fg = "#b294bb" })
hi(0, "@keyword.faded", { fg = "#666d78" })
hi(0, "@label", { fg = "#f8fe7a" })
hi(0, "@module", { fg = "#b294bb" })
hi(0, "@normal", { bg = "#111111", fg = "#e0e0e0" })
hi(0, "@number", { fg = "#cc6666" })
hi(0, "@property", { fg = "#81a2be" })
hi(0, "@tag.attribute.html", { fg = "#b294bb" })
hi(0, "@tag.delimiter.html", { fg = "#a3bbcf" })
hi(0, "@type", { fg = "#b294bb", italic = true })
hi(0, "@type.builtin", { bold = true, fg = "#b294bb" })
hi(0, "@variable", { fg = "#e0e0e0" })
hi(0, "@variable.builtin", { bg = "#111111", fg = "#c5b5dd" })
hi(0, "Boolean", { fg = "#de935f" })
hi(0, "Character", { fg = "#cc6666" })
hi(0, "Comment", { fg = "#b0b1b0", italic = true })
hi(0, "Conceal", { bg = "#4e545d", fg = "#111111", italic = true })
hi(0, "Conditional", { fg = "#b294bb" })
hi(0, "Constant", { bold = true, fg = "#de935f" })
hi(0, "Cursor", { bg = "#e0e0e0", fg = "#111111" })
hi(0, "CursorLine", { bg = "#2b2b2b" })
hi(0, "Define", { fg = "#8abeb7" })
hi(0, "DiagnosticError", { bold = true, fg = "#cc6666" })
hi(0, "DiagnosticErrorStatusline", { bg = "#81a2be", fg = "#cc6666" })
hi(0, "DiagnosticHintStatusline", { bg = "#81a2be", fg = "#a6dbff" })
hi(0, "DiagnosticInfo", { fg = "#8cf8f7" })
hi(0, "DiagnosticInfoStatusline", { bg = "#81a2be", fg = "#8cf8f7" })
hi(0, "DiagnosticWarn", { fg = "#fce094" })
hi(0, "DiagnosticWarnStatusline", { bg = "#81a2be", fg = "#fce094" })
hi(0, "DiffAdd", { bg = "#33423e" })
hi(0, "DiffChange", { bg = "#33423e" })
hi(0, "DiffDelete", { bg = "#24282f", fg = "#3a414c" })
hi(0, "DiffText", { bg = "#3e4a47" })
hi(0, "Directory", { fg = "#e7b089" })
hi(0, "EndOfBuffer", { fg = "#969896" })
hi(0, "Error", { bold = true, fg = "#d98c8c" })
hi(0, "EyelinerDimmed", { fg = "#b0b1b0" })
hi(0, "EyelinerPrimary", { fg = "#de935f" })
hi(0, "EyelinerSecondary", { fg = "#8abeb7" })
hi(0, "Float", { fg = "#cc6666" })
hi(0, "FloatBorder", { bg = "#000000", fg = "#2b2b2b" })
hi(0, "Folded", { bg = "#4e545d", fg = "#7c7f7c" })
hi(0, "Function", { bold = true, fg = "#f8fe7a" })
hi(0, "GrappleBold", { bold = true })
hi(0, "GrappleCurrent", { fg = "#a3685a" })
hi(0, "HeadlineReverse", { fg = "#4f5258" })
hi(0, "IblIndent", { fg = "#8e6fbd" })
hi(0, "IblScope", { bg = "#111111", fg = "#282a2e" })
hi(0, "IblWhitespace", { fg = "#8e6fbd" })
hi(0, "Identifier", { fg = "#e0e0e0" })
hi(0, "Include", { fg = "#8abeb7" })
hi(0, "Keyword", { fg = "#b294bb" })
hi(0, "Label", { fg = "#f8fe7a" })
hi(0, "LineNr", { bg = "#111111", fg = "#282a2e" })
hi(0, "LspReferenceRead", { bg = "#2b2b2b" })
hi(0, "LspReferenceWrite", { bg = "#2b2b2b" })
hi(0, "MatchParen", { fg = "#8abeb7" })
hi(0, "MiniCursorword", { underline = true })
hi(0, "MiniCursorwordCurrent", {})
hi(0, "NonText", { fg = "#4e545d", italic = true })
hi(0, "Normal", { bg = "#111111", fg = "#e0e0e0" })
hi(0, "NormalFloat", { bg = "#000000", fg = "#fafafa" })
hi(0, "Number", { fg = "#cc6666" })
hi(0, "Operator", { fg = "#e6b3b3" })
hi(0, "Pmenu", { bg = "#373b41", fg = "#b4b7b4" })
hi(0, "PmenuSbar", { bg = "#111111" })
hi(0, "PmenuSel", { bg = "#fbfead", fg = "#111111" })
hi(0, "PmenuThumb", { bg = "#b4b7b4" })
hi(0, "PreProc", { fg = "#f8fe7a" })
hi(0, "Repeat", { fg = "#cc6666" })
hi(0, "Search", { bg = "#f8fe7a", fg = "#282a2e" })
hi(0, "SignColumn", { bg = "#111111", fg = "#404349" })
hi(0, "Special", { bold = true, fg = "#a992cd" })
hi(0, "SpecialChar", { fg = "#a3685a" })
hi(0, "SpectreBody", { link = "String" })
hi(0, "SpectreBorder", { link = "Comment" })
hi(0, "SpectreDir", { link = "Comment" })
hi(0, "SpectreFile", { link = "Keyword" })
hi(0, "SpectreHeader", { link = "Comment" })
hi(0, "SpectreReplace", { link = "DiffDelete" })
hi(0, "SpectreSearch", { link = "DiffChange" })
hi(0, "Statement", { fg = "#bf4040" })
hi(0, "StatusLine", { bg = "#81a2be", fg = "#373b41" })
hi(0, "StatusLineNC", { bg = "#404349", fg = "#969896" })
hi(0, "StorageClass", { fg = "#f8fe7a" })
hi(0, "String", { fg = "#99cc99" })
hi(0, "Structure", { fg = "#b294bb" })
hi(0, "TabLine", { bg = "#282a2e", fg = "#5f89ad" })
hi(0, "TabLineFill", { bg = "#969896", fg = "#ebdbb2" })
hi(0, "TabLineSel", { bg = "#282a2e", bold = true, fg = "#ffffff" })
hi(0, "Tag", { fg = "#f8fe7a" })
hi(0, "Todo", { fg = "#f8fe7a" })
hi(0, "Type", { fg = "#b294bb", italic = true })
hi(0, "Typedef", { fg = "#f8fe7a" })
hi(0, "Visual", { bg = "#5f89ad" })
hi(0, "Whitespace", { fg = "#8e6fbd" })
hi(0, "commandmode", { bg = "#99cc99", bold = true, fg = "#ffffff" })
hi(0, "diffadded", { fg = "#99cc99" })
hi(0, "diffremoved", { fg = "#cc6666" })
hi(0, "gitdiff", { fg = "#c7c7c7" })
hi(0, "helpdoc", { bg = "#698b69", bold = true, fg = "#ffffff", italic = true })
hi(0, "helpignore", { bold = true, fg = "#99cc99", italic = true })
hi(0, "htmlBold", { bold = true })
hi(0, "htmlBoldItalic", { bold = true, italic = true })
hi(0, "htmlBoldUnderline", { bold = true, underline = true })
hi(0, "htmlBoldUnderlineItalic", { bold = true, italic = true, underline = true })
hi(0, "htmlItalic", { italic = true })
hi(0, "htmlStrike", { strikethrough = true })
hi(0, "htmlUnderline", { underline = true })
hi(0, "htmlUnderlineItalic", { italic = true, underline = true })
hi(0, "htmlh1", { fg = "#81a2be" })
hi(0, "insertmode", { bg = "#f8fe7a", bold = true, fg = "#ffffff" })
hi(0, "invnormal", { bg = "#c5c8c6", fg = "#111111" })
hi(0, "lCursor", { bg = "#e0e0e0", fg = "#111111" })
hi(0, "markdownh1", { bold = true, fg = "#81a2be", italic = true })
hi(0, "markdownh2", { bold = true, fg = "#a3bbcf" })
hi(0, "markdownh3", { fg = "#c4d4e1", italic = true })
hi(0, "normalmode", { bg = "#cc6666", bold = true, fg = "#ffffff" })
hi(0, "qffilename", { bold = true, fg = "#f8fe7a" })
hi(0, "replacemode", { bg = "#f8fe7a", bold = true, fg = "#ffffff", underline = true })
hi(0, "telescopematching", { bold = true, fg = "#e89155" })
hi(0, "terminalmode", { bg = "#698b69", bold = true, fg = "#ffffff" })
hi(0, "user1", { bg = "#f8fe7a", bold = true, fg = "#ffffff" })
hi(0, "user2", { bg = "#cc6666", bold = true, fg = "#ffffff" })
hi(0, "user3", { bg = "#99cc99", bold = true, fg = "#ffffff" })
hi(0, "variable", { fg = "#e0e0e0" })
hi(0, "visuallinemode", { bg = "#5f89ad" })
hi(0, "visualmode", { bg = "#5f89ad" })

-- No terminal colors defined
