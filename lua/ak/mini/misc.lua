-- Miscellaneous small but useful functions. Example usage:
-- - `<Leader>oz` - toggle between "zoomed" and regular view of current buffer
-- - `<Leader>or` - resize window to its "editable width"
-- - `:lua put_text(vim.lsp.get_clients())` - put output of a function below
--   cursor in current buffer. Useful for a detailed exploration.
-- - `:lua put(MiniMisc.stat_summary(MiniMisc.bench_time(f, 100)))` - run
--   function `f` 100 times and report statistical summary of execution times
--
-- Makes `:h MiniMisc.put()` and `:h MiniMisc.put_text()` public
require('mini.misc').setup()

-- Change current working directory based on the current file path. It
-- searches up the file tree until the first root marker ('.git' or 'Makefile')
-- and sets their parent directory as a current directory.
-- This is helpful when simultaneously dealing with files from several projects.
MiniMisc.setup_auto_root()

-- Restore latest cursor position on file open
MiniMisc.setup_restore_cursor()

-- Synchronize terminal emulator background with Neovim's background to remove
-- possibly different color padding around Neovim instance
MiniMisc.setup_termbg_sync()
