-- :help quickfixtextfunc

-- Override leader x defined in keymaps
vim.keymap.set("n", "<leader>x", function() require("quicker").toggle() end, {
  desc = "Toggle quickfix",
})

local expand = function() require("quicker").expand({ before = 2, after = 2, add_to_existing = true }) end
local collapse = function() require("quicker").collapse() end
require("quicker").setup({
  keys = {
    { ">", expand, desc = "Expand quickfix context" },
    { "<", collapse, desc = "Collapse quickfix context" },
  },
})
