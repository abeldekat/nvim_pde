-- https://github.com/ThePrimeagen/harpoon/pull/514/commits/fedfcc67b152be40d972008b39c09c63cdf5c014
-- https://github.com/ThePrimeagen/harpoon/issues/490
--
-- TODO: Telescope for files across lists

local Harpoon = require("harpoon")
local Extensions = require("harpoon.extensions")
local Util = require("ak.util")
local A = {} -- actions used
local H = {} -- helpers

---@class AkHarpoonState
H.state = {
  list_name = "-",
  list_length = 0,
  idx = -1, -- position of current buff in the list
}
-- "-" is a custom label for harpoon's default list
H.lists = { "-", "dev" }

function H.get_list()
  local name = H.state.list_name
  return Harpoon:list(name ~= "-" and name or nil)
end

function H.name_of_next_list()
  local function current_idx()
    for idx, name in ipairs(H.lists) do
      if name == H.state.list_name then return idx end
    end
  end
  local idx = current_idx()
  return H.lists[idx == #H.lists and 1 or idx + 1]
end

function H.buffer_idx()
  -- For more information see ":h buftype"
  local not_found = -1
  if vim.bo.buftype ~= "" then return not_found end -- not a normal buffer

  -- local current_file = vim.api.nvim_buf_get_name(0):gsub(vim.fn.getcwd() .. "/", "")
  local current_file = vim.fn.expand("%:p:.")
  local marks = H.get_list().items
  for idx, item in ipairs(marks) do
    if item.value == current_file then return idx end
  end
  return not_found
end

function H.update_state()
  H.state.list_length = H.get_list():length()
  H.state.idx = H.buffer_idx()
  vim.api.nvim_exec_autocmds("User", {
    pattern = "HarpoonStateChanged",
    modeline = false,
  })
end

function A.append()
  H.get_list():append()
  H.update_state()
end
function A.switch_list()
  H.state.list_name = H.name_of_next_list()
  H.update_state()
end
function A.ui() Harpoon.ui:toggle_quick_menu(H.get_list()) end
function A.prev() H.get_list():prev() end
function A.next() H.get_list():next() end
function A.select(index) H.get_list():select(index) end

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

local opts = {
  settings = {
    save_on_toggle = true, -- default false,
    sync_on_ui_close = false,
    key = function() return vim.loop.cwd() end,
  },
  -- default = {}, -- ...it is simply a file harpoon
  --          ╭─────────────────────────────────────────────────────────╮
  --          │ Named list configs. Merged with default overriding any  │
  --          │                        behavior                         │
  --          ╰─────────────────────────────────────────────────────────╯
  [H.lists[2]] = {},
}

add_keys()
Harpoon:extend({ [Extensions.event_names.SETUP_CALLED] = H.update_state }) --

---@diagnostic disable-next-line: redundant-parameter
Harpoon:setup(opts)
Util.harpoon.setup(H.state)
vim.api.nvim_create_autocmd({ "BufEnter" }, {
  pattern = "*",
  callback = H.update_state,
})
