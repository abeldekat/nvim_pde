-- Go to last loc when opening a buffer: See mini.misc
local function augroup(name) return vim.api.nvim_create_augroup("abeldekat_" .. name, {}) end
local autocmd = vim.api.nvim_create_autocmd

autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
  group = augroup("checktime"), -- check if file needs to be reloaded when it changed
  callback = function()
    if vim.o.buftype ~= "nofile" then vim.cmd("checktime") end
  end,
})

autocmd("TextYankPost", { -- highlight on yank
  group = augroup("highlight_yank"),
  callback = function() vim.hl.on_yank() end,
})

autocmd({ "VimResized" }, { -- resize splits if window got resized
  group = augroup("resize_splits"),
  callback = function()
    local current_tab = vim.fn.tabpagenr()
    vim.cmd("tabdo wincmd =")
    vim.cmd("tabnext " .. current_tab)
  end,
})

-- Close some filetypes with <q>
-- stylua: ignore start
autocmd("FileType", {
  group = augroup("close_with_q"),
  pattern = {
    "help", "lspinfo", "qf", "checkhealth", "neotest-output", "neotest-summary",
    "neotest-output-panel", "dbout", "git", "minideps-confirm","mininotify-history"
  },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = event.buf, silent = true })
  end,
})
-- stylua: ignore end

vim.api.nvim_create_autocmd("FileType", { -- close man-files when opened inline
  group = augroup("man_unlisted"),
  pattern = { "man" },
  callback = function(event) vim.bo[event.buf].buflisted = false end,
})

vim.api.nvim_create_autocmd({ "FileType" }, { -- fix conceallevel for json files
  group = augroup("json_conceal"),
  pattern = { "json", "jsonc", "json5" },
  callback = function()
    vim.wo.spell = false
    vim.opt_local.conceallevel = 0
  end,
})

autocmd({ "BufWritePre" }, { -- auto create dir when saving a file
  group = augroup("auto_create_dir"),
  callback = function(event)
    if event.match:match("^%w%w+://") then return end
    local file = vim.uv.fs_realpath(event.match) or event.match
    vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
  end,
})

autocmd("Filetype", { -- don't continue comments with o and O
  group = augroup("continue_comments"),
  callback = function()
    -- Don't auto-wrap comments and don't insert comment leader after hitting 'o'
    -- If don't do this on `FileType`, this keeps reappearing due to being set in
    -- filetype plugins.
    vim.cmd("setlocal formatoptions-=c formatoptions-=o")
  end,
  desc = [[Ensure proper 'formatoptions']],
})
