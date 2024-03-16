-- https://github.com/ThePrimeagen/harpoon/pull/514/commits/fedfcc67b152be40d972008b39c09c63cdf5c014
-- https://github.com/ThePrimeagen/harpoon/issues/490
--
-- TODO: Telescope for files across lists

local Harpoon = require("harpoon")
local has_harpoon_line, HarpoonLine = pcall(require, "harpoon_line")

local A = {} -- actions triggered by keys
local H = {} -- helper functionality

H.current_list_placeholder = "default" -- the default harpoon list is nil...
H.current_list = H.current_list_placeholder
H.lists = { H.current_list_placeholder }

H.harpoon_list = function()
  return H.current_list ~= H.current_list_placeholder and H.current_list or nil --
end
H.get_list = function()
  return Harpoon:list(H.harpoon_list()) --
end
H.name_of_next_list = function()
  local function current_idx()
    for idx, name in ipairs(H.lists) do
      if name == H.current_list then return idx end
    end
  end
  local idx = current_idx()
  return H.lists[idx == #H.lists and 1 or idx + 1]
end

A.switch_list = function()
  H.current_list = H.name_of_next_list()
  if has_harpoon_line then HarpoonLine.change_list(H.harpoon_list()) end
end
A.append = function() H.get_list():append() end
A.ui = function() Harpoon.ui:toggle_quick_menu(H.get_list()) end
A.prev = function() H.get_list():prev() end
A.next = function() H.get_list():next() end
A.select = function(index) H.get_list():select(index) end

local function add_keys()
  vim.keymap.set("n", "<leader>J", A.switch_list, { desc = "Switch harpoon list", silent = true })
  vim.keymap.set("n", "<leader>h", A.append, { desc = "Harpoon append", silent = true })
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
    settings = {
      save_on_toggle = true, -- default false,
      sync_on_ui_close = false,
      key = function() return vim.loop.cwd() end,
    },
    -- default = {}, -- ...it is simply a file harpoon
  }
  --          ╭─────────────────────────────────────────────────────────╮
  --          │ Named list configs. Merged with default overriding any  │
  --          │                        behavior                         │
  --          ╰─────────────────────────────────────────────────────────╯
  for idx, list in ipairs(extra_lists) do
    opts[list] = extra_list_configs[idx]
  end
  add_keys()

  ---@diagnostic disable-next-line: redundant-parameter
  Harpoon:setup(opts)
  if has_harpoon_line then HarpoonLine:setup() end
  H.lists = vim.list_extend(H.lists, extra_lists)
end
setup()
