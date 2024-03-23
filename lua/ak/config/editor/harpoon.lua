-- https://github.com/ThePrimeagen/harpoon/pull/514/commits/fedfcc67b152be40d972008b39c09c63cdf5c014
-- https://github.com/ThePrimeagen/harpoon/issues/490
-- https://github.com/ThePrimeagen/harpoon/issues/523
-- https://github.com/ThePrimeagen/harpoon/issues/352

local Harpoon = require("harpoon")
local Extensions = require("harpoon.extensions")
local Path = require("plenary.path")

local H = {} -- helper functionality
local A = {} -- actions triggered by keys
local L = {} -- harpoon config functions

H.current_list_placeholder = "default" -- the default harpoon list is nil...
H.current_list = H.current_list_placeholder
H.lists = { H.current_list_placeholder }

H.to_harpoon_name = function()
  return H.current_list ~= H.current_list_placeholder and H.current_list or nil --
end
H.get_current_list = function() return Harpoon:list(H.to_harpoon_name()) end
H.name_of_next_list = function()
  local function current_idx()
    for idx, name in ipairs(H.lists) do
      if name == H.current_list then return idx end
    end
  end
  local idx = current_idx()
  return H.lists[idx == #H.lists and 1 or idx + 1]
end

-- Display filename only, two spaces and normalized filename
---@param list_item HarpoonListItem
---@return string
L.display = function(list_item) return vim.fs.basename(list_item.value) .. "  " .. list_item.value end
-- Set cursor on mark of current file if possible
-- Highlight the line of that mark
L.on_ui_create = function(args) -- HarpoonToggleOptions
  -- --@type number
  -- local bufnr = args.bufnr -- or 0 on error
  -- --@type number
  -- local win_id = args.win_id -- or 0 on error
  --@type string
  local current_file = args.current_file
  local file_normalized = Path:new(current_file):normalize()

  local mark = nil
  for idx, item in ipairs(H.get_current_list().items) do
    if item.value == file_normalized then mark = idx end
  end
  if not mark then return end

  vim.api.nvim_win_set_cursor(0, { mark, 0 })

  -- NOTE: See harpoon buffer.lua setup_autocmds_and_keymaps(bufnr)
  -- The autocmd on Filetype harpoon fails to match, because path is empty
  vim.fn.clearmatches()
  -- vim.fn.matchadd("CursorLine", file_normalized)
  vim.fn.matchadd("MiniHipatternsHack", file_normalized)
end

A.switch_list = function()
  H.current_list = H.name_of_next_list()
  vim.api.nvim_exec_autocmds("User", { pattern = "HarpoonSwitchedList", modeline = false, data = H.to_harpoon_name() })
end
A.append = function() H.get_current_list():append() end
A.ui = function() Harpoon.ui:toggle_quick_menu(H.get_current_list()) end
A.prev = function() H.get_current_list():prev() end
A.next = function() H.get_current_list():next() end
A.select = function(index) H.get_current_list():select(index) end

local function add_keys()
  vim.keymap.set("n", "<leader>J", A.switch_list, { desc = "Switch harpoon list", silent = true })
  vim.keymap.set("n", "<leader>a", A.append, { desc = "Harpoon append", silent = true })
  vim.keymap.set("n", "<leader>j", A.ui, { desc = "Harpoon ui", silent = true })
  vim.keymap.set("n", "<leader>n", A.next, { desc = "Harpoon next", silent = true })
  vim.keymap.set("n", "<leader>p", A.prev, { desc = "Harpoon prev", silent = true })
  --
  vim.keymap.set("n", "<c-j>", function() A.select(1) end, { desc = "Harpoon 1", silent = true })
  vim.keymap.set("n", "<c-k>", function() A.select(2) end, { desc = "Harpoon 2", silent = true })
  vim.keymap.set("n", "<c-l>", function() A.select(3) end, { desc = "Harpoon 3", silent = true })
  vim.keymap.set("n", "<c-h>", function() A.select(4) end, { desc = "Harpoon 4", silent = true })
end

local function setup()
  local extra_lists = { "dev" }
  local extra_list_configs = { {} }

  local opts = {
    settings = { save_on_toggle = true, sync_on_ui_close = false },
    -- ...it is simply a file harpoon:
    default = { display = L.display },
  }
  --          ╭─────────────────────────────────────────────────────────╮
  --          │ Named list configs. Merged with default overriding any  │
  --          │                        behavior                         │
  --          ╰─────────────────────────────────────────────────────────╯
  for idx, list in ipairs(extra_lists) do
    opts[list] = extra_list_configs[idx]
  end
  H.lists = vim.list_extend(H.lists, extra_lists)

  add_keys()

  ---@diagnostic disable-next-line: redundant-parameter
  Harpoon:setup(opts)
  Harpoon:extend({ [Extensions.event_names.UI_CREATE] = L.on_ui_create }) --
end
setup()
