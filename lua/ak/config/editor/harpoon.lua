local list_names = { "default", "dev" } -- add an extra list
local list_name = nil -- default harpoon list

-- stylua: ignore start
local function append()
  require("harpoon"):list(list_name):append()
end
local function ui()
  require("harpoon").ui:toggle_quick_menu(require("harpoon"):list(list_name))
end
local function select(index)
  require("harpoon"):list(list_name):select(index)
end
local function prev()
  require("harpoon"):list(list_name):prev()
end
local function next()
  require("harpoon"):list(list_name):next()
end
local function select_list()
  vim.ui.select(list_names, {
    prompt = "Harpoon lists",
  }, function(item)
    list_name = item and item ~= "default" and item or nil
  end)
end
-- stylua: ignore end

local opts = {
  settings = {
    save_on_toggle = true, -- default false,
    sync_on_ui_close = false,
    key = function() return vim.loop.cwd() end,
  },
  ["dev"] = {}, --> the new list
}
local harpoon = require("harpoon")
harpoon:setup(opts)
harpoon:extend({}) --> TODO: extensions

vim.keymap.set("n", "<leader>h", append, { desc = "Harpoon append", silent = true })
vim.keymap.set("n", "<leader>j", ui, { desc = "Harpoon ui", silent = true })
vim.keymap.set("n", "<leader>J", select_list, { desc = "Select harpoon list", silent = true })
vim.keymap.set("n", "<leader>n", next, { desc = "Harpoon next", silent = true })
vim.keymap.set("n", "<leader>p", prev, { desc = "Harpoon prev", silent = true })
vim.keymap.set("n", "<c-j>", function() select(1) end, { desc = "Harpoon 1", silent = true })
vim.keymap.set("n", "<c-k>", function() select(2) end, { desc = "Harpoon 2", silent = true })
vim.keymap.set("n", "<c-l>", function() select(3) end, { desc = "Harpoon 3", silent = true })
vim.keymap.set("n", "<c-h>", function() select(4) end, { desc = "Harpoon 4", silent = true })
