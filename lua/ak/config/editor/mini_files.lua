--[[

- "Go in plus" is regular "Go in" but closes explorer after opening a file.
- "Go out plus" is regular "Go out" but trims right part of branch.
...
- If `options.permanent_delete` is `true`, delete is permanent. Otherwise
  file system entry is moved to a module-specific trash directory
  (see |MiniFiles.config| for more details).

-- NOTE: visits_harpooned, add a directory via netrw: :Ex

--]]
local minifiles = require("mini.files")
local config = {
  windows = {
    preview = true,
  },
}
minifiles.setup(config)

local minifiles_augroup = vim.api.nvim_create_augroup("ek-mini-files", {})

vim.api.nvim_create_autocmd("User", { -- bookmarks, alternative is visits_harpooned
  group = minifiles_augroup,
  pattern = "MiniFilesExplorerOpen",
  callback = function()
    MiniFiles.set_bookmark("c", vim.fn.stdpath("config") .. "", { desc = "Config" })
    MiniFiles.set_bookmark("m", vim.fn.stdpath("data") .. "/site/pack/deps/start/mini.nvim", { desc = "mini.nvim" })
    MiniFiles.set_bookmark("p", vim.fn.stdpath("data") .. "/site/pack/deps/opt", { desc = "Plugins" })
    MiniFiles.set_bookmark("w", vim.fn.getcwd, { desc = "Working directory" })
  end,
})

local show_dotfiles = true
local filter_show = function(_) return true end
local filter_hide = function(fs_entry) return not vim.startswith(fs_entry.name, ".") end
local toggle_dotfiles = function()
  show_dotfiles = not show_dotfiles
  local new_filter = show_dotfiles and filter_show or filter_hide
  MiniFiles.refresh({ content = { filter = new_filter } })
end
vim.api.nvim_create_autocmd("User", { -- toggle dotfiles
  group = minifiles_augroup,
  pattern = "MiniFilesBufferCreate",
  callback = function(args)
    local buf_id = args.data.buf_id
    vim.keymap.set("n", "g.", toggle_dotfiles, { buffer = buf_id })
  end,
})

vim.keymap.set("n", "mk", function()
  local ft = vim.bo.filetype
  MiniFiles.open(ft and ft ~= "ministarter" and vim.api.nvim_buf_get_name(0) or nil)
end, { desc = "Minfiles open directory", silent = true })
