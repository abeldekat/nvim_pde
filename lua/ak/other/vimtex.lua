-- ...only vimscript variables

-- ...The two exceptions are code folding and formatting, which are disabled by default and must be manually enabled...
--
-- Note: mini.clue, localleader triggers not that useful. Use mini.pick and search for "\"
-- \ll start or stop compiling
-- \lk stop compilation process
-- \lc clear auxiliary files
-- has motions and textobjects

vim.g.vimtex_view_method = "zathura" -- default is browser...
-- vim.g.vimtex_view_general_viewer = "evince"

vim.g.vimtex_mappings_disable = { ["n"] = { "K" } } -- disable `K` as it conflicts with LSP hover...

-- vim.g.vimtex_quickfix_method = vim.fn.executable("pplatex") == 1 and "pplatex" or "latexlog"
vim.g.vimtex_quickfix_method = "latexlog" -- pplatex is in arch aur...

vim.g.vimtex_fold_enabled = 1 -- can be slow?
vim.g.vimtex_fold_manual = 1 -- this is not really manual...

-- https://github.com/lervag/vimtex/issues/2959:
vim.g.vimtex_compiler_latexmk_engines = { _ = "-lualatex" }
-- Notice that this is a different approach for changing the compiler engine.
-- I personally prefer using this approach, because it is also recognized by other editors.
-- So, as a sensible solution, I think you should simplify your config to something like the following
-- and then use the tex program directive for specifying the engine:
-- %! TeX program = lualatex

vim.g.vimtex_compiler_latexmk = { out_dir = "build" }
