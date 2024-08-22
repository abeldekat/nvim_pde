local misc = require("mini.misc")
misc.setup() -- misc provides a make_global option...

-- Cursor
misc.setup_restore_cursor()

-- Terminal: misc.setup_termbg_sync() -- not working in tmux

-- Zoom
vim.keymap.set("n", "<leader>uz", function() misc.zoom() end, { desc = "Toggle zoom buffer", silent = true })

-- Customized:

-- Customize MiniMisc.setup_auto_root. WIP

-- local MiniMiscCustomized = {}
-- local HM = {} -- MiniMisc utilities, mostly copied

-- MiniMiscCustomized.setup_auto_root = function(names, fallback)
--   names = names or { ".git", "Makefile" }
--   if not (HM.is_array_of(names, HM.is_string) or vim.is_callable(names)) then
--     HM.error("Argument `names` of `setup_auto_root()` should be array of string file names or a callable.")
--   end
--
--   fallback = fallback or function() return nil end
--   if not vim.is_callable(fallback) then HM.error("Argument `fallback` of `setup_auto_root()` should be callable.") end
--
--   -- Disable conflicting option
--   vim.o.autochdir = false
--
--   -- Create autocommand
--   local set_root = function(data)
--     local root = MiniMiscCustomized.find_root(data.buf, names, fallback)
--     if root == nil then return end
--     vim.fn.chdir(root)
--   end
--   local augroup = vim.api.nvim_create_augroup("MiniMiscCustomizedAutoRoot", {})
--   vim.api.nvim_create_autocmd(
--     "BufEnter",
--     { group = augroup, callback = set_root, desc = "Find root and change current directory" }
--   )
-- end

-- MiniMiscCustomized.find_root = function(buf_id, names, fallback)
--   buf_id = buf_id or 0
--   names = names or { ".git", "Makefile" }
--   fallback = fallback or function() return nil end
--
--   if type(buf_id) ~= "number" then HM.error("Argument `buf_id` of `find_root()` should be number.") end
--   if not (HM.is_array_of(names, HM.is_string) or vim.is_callable(names)) then
--     HM.error("Argument `names` of `find_root()` should be array of string file names or a callable.")
--   end
--   if not vim.is_callable(fallback) then HM.error("Argument `fallback` of `find_root()` should be callable.") end
--
--   -- Compute directory to start search from. NOTEs on why not using file path:
--   -- - This has better performance because `vim.fs.find()` is called less.
--   -- - *Needs* to be a directory for callable `names` to work.
--   -- - Later search is done including initial `path` if directory, so this
--   --   should work for detecting buffer directory as root.
--   local path = vim.api.nvim_buf_get_name(buf_id)
--   if path == "" then return end
--   local dir_path = vim.fs.dirname(path)
--
--   -- Try using cache
--   local res = HM.root_cache[dir_path]
--   if res ~= nil then return res end
--
--   -- Find root
--   local root_file = vim.fs.find(names, { path = dir_path, upward = true })[1]
--   if root_file ~= nil then
--     res = vim.fs.dirname(root_file)
--   else
--     res = fallback(path)
--   end
--
--   -- Use absolute path to an existing directory
--   if type(res) ~= "string" then return end
--   res = HM.fs_normalize(vim.fn.fnamemodify(res, ":p"))
--   if vim.fn.isdirectory(res) == 0 then return end
--
--   -- Cache result per directory path
--   HM.root_cache[dir_path] = res
--
--   return res
-- end

-- -- TODO: Remove after compatibility with Neovim=0.9 is dropped
-- ---@diagnostic disable-next-line: deprecated
-- HM.islist = vim.fn.has("nvim-0.10") == 1 and vim.islist or vim.tbl_islist
--
-- HM.is_string = function(x) return type(x) == "string" end
--
-- HM.is_array_of = function(x, predicate)
--   if not HM.islist(x) then return false end
--   for _, v in ipairs(x) do
--     if not predicate(v) then return false end
--   end
--   return true
-- end
--
-- HM.error = function(msg) error("(mini.misc) " .. msg) end
--
-- HM.root_cache = {}
--
-- HM.fs_normalize = vim.fs.normalize
-- if vim.fn.has("nvim-0.9") == 0 then
--   HM.fs_normalize = function(...) return vim.fs.normalize(...):gsub("(.)/+$", "%1") end
-- end

-- Apply MiniMiscCustomized.setup_auto_root
-- MiniMiscCustomized.setup_auto_root()
