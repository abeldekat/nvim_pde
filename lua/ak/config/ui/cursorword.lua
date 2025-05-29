-- Also possible: native lsp vim.lsp.handlers["textDocument/documentHighlight"]

require("mini.cursorword").setup()
vim.cmd("hi! MiniCursorwordCurrent guifg=NONE guibg=NONE gui=NONE cterm=NONE")
