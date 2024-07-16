vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

local opt = vim.opt
vim.schedule(function() -- includes system call responsible for 40% startuptime!
  opt.clipboard = vim.env.SSH_TTY and "" or "unnamedplus" -- Sync with system clipboard
end)

opt.autowrite = true -- Enable auto write
opt.breakindent = true
opt.completeopt = "menu,menuone,noselect"
opt.conceallevel = 2 -- Hide * markup for bold and italic, but not markers with substitutions
opt.confirm = true -- Confirm to save changes before exiting modified buffer
opt.cursorline = true -- Enable highlighting of the current line
opt.expandtab = true -- Use spaces instead of tabs

-- opt.fillchars = "fold: " -- overriding earlier fillchars?
opt.fillchars = {
  foldopen = "",
  foldclose = "",
  -- fold = " ",
  foldsep = " ",
  diff = "╱",
  eob = " ",
}

-- Folding:
opt.foldlevel = 99
opt.foldmethod = "expr"
opt.foldexpr = "nvim_treesitter#foldexpr()"
-- opt.foldtext = ""

opt.formatoptions = "jcroqlnt" -- tcqj
opt.grepformat = "%f:%l:%c:%m"
opt.grepprg = "rg --vimgrep"
opt.ignorecase = true -- Ignore case
-- opt.inccommand = "nosplit" -- preview incremental substitute
-- Preview substitutions live, as you type!
opt.inccommand = "split" -- kickstart
opt.jumpoptions = "view" -- TEST:
opt.laststatus = 3 -- global statusline
opt.linebreak = true
opt.list = true -- Show some invisible characters (tabs...
opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" } -- kickstart
opt.mouse = "" -- Disable mouse mode
opt.number = true -- Print line number
-- opt.pumblend = 10 -- Popup blend
-- opt.pumheight = 10 -- Maximum number of entries in a popup
opt.relativenumber = true -- Relative line numbers
opt.scrolloff = 4 -- Lines of context
opt.sessionoptions = { "buffers", "curdir", "tabpages", "winsize", "help", "globals", "skiprtp", "folds" }
opt.shiftround = true -- Round indent
opt.shiftwidth = 2 -- Size of an indent
opt.shortmess:append({ W = true, I = true, c = true, C = true })
opt.showmode = false -- Dont show mode since we have a statusline
opt.sidescrolloff = 6 -- Columns of context, used to be 8
opt.signcolumn = "yes" -- Always show the signcolumn, otherwise it would shift the text each time
opt.smartcase = true -- Don't ignore case with capitals
opt.smartindent = true -- Insert indents automatically
opt.smoothscroll = true
opt.spelllang = { "en" }
opt.spelloptions:append("noplainbuffer") -- when available, treesitter spell regions
opt.splitbelow = false -- Put new windows below current
opt.splitkeep = "screen"
opt.splitright = false -- Put new windows right of current
opt.tabstop = 2 -- Number of spaces tabs count for
-- opt.termguicolors = true -- True color support
opt.timeoutlen = 600 -- 300
opt.undofile = true
opt.undolevels = 10000
opt.updatetime = 200 -- Save swap file and trigger CursorHold
opt.virtualedit = "block" -- Allow cursor to move where there is no text in visual block mode
opt.wildmode = "longest:full,full" -- Command-line completion mode
opt.winminwidth = 5 -- Minimum window width
opt.wrap = false -- Disable line wrap

-- Fix markdown indentation settings
vim.g.markdown_recommended_style = 0

--          ╭─────────────────────────────────────────────────────────╮
--          │                         ADDED                           │
--          ╰─────────────────────────────────────────────────────────╯

-- basic
opt.showtabline = 0 -- never show tabs, 1 is default, 2, -- always show tabs
opt.colorcolumn = "80"
-- opt.cmdheight = 0 -- on write, the statusline disappears
opt.guicursor = ""

-- splits
-- vim.opt.splitbelow = false -- Put new windows below current
-- vim.opt.splitright = false -- Put new windows right of current

-- checkhealth:
vim.g.python3_host_prog = "/usr/bin/python" -- archlinux: global python-pynvim

-- allow local .nvim.lua .vimrc .exrc files
-- vim.opt.exrc = true

-- checkhealth:
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0
-- vim.g.loaded_node_provider = 0
-- vim.g.loaded_python3_provider = 0
