-- stylua: ignore start
local function append()
  require("harpoon.mark").add_file()
end
local function ui()
  require("harpoon.ui").toggle_quick_menu()
end
local function select(index)
  require("harpoon.ui").nav_file(index)
end
local function prev()
  require("harpoon.ui").nav_prev()
end
local function next()
  require("harpoon.ui").nav_next()
end
local function to_terminal()
  local num = tonumber(vim.fn.input("Terminal window number: "))
  require("harpoon.term").gotoTerminal(num)
end
-- stylua: ignore end

require("harpoon").setup({ tabline = false })

vim.keymap.set("n", "<leader>h", append, { desc = "Harpoon append", silent = true })
vim.keymap.set("n", "<leader>j", ui, { desc = "Harpoon ui", silent = true })
vim.keymap.set("n", "<leader>n", next, { desc = "Harpoon next", silent = true })
vim.keymap.set("n", "<leader>p", prev, { desc = "Harpoon prev", silent = true })

vim.keymap.set("n", "<c-j>", function() select(1) end, { desc = "Harpoon 1", silent = true })
vim.keymap.set("n", "<c-k>", function() select(2) end, { desc = "Harpoon 2", silent = true })
vim.keymap.set("n", "<c-l>", function() select(3) end, { desc = "Harpoon 3", silent = true })
vim.keymap.set("n", "<c-h>", function() select(4) end, { desc = "Harpoon 4", silent = true })
vim.keymap.set("n", "<leader>fh", to_terminal, { desc = "Harpoon terminal", silent = true })
