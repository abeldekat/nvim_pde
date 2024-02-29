--          ╭─────────────────────────────────────────────────────────╮
--          │               DEPRECATED in favor of leap               │
--          ╰─────────────────────────────────────────────────────────╯

--          ╭─────────────────────────────────────────────────────────╮
--          │                          deps:                          │
--          ╰─────────────────────────────────────────────────────────╯
-- add("folke/flash.nvim")
-- require("ak.config.editor.flash")
-- add("jinh0/eyeliner.nvim")
-- require("ak.config.editor.eyeliner")

--          ╭─────────────────────────────────────────────────────────╮
--          │                          lazy:                          │
--          ╰─────────────────────────────────────────────────────────╯
-- {
--     "folke/flash.nvim",
--     event = "VeryLazy",
--     dependencies = "jinh0/eyeliner.nvim",
--     config = function()
--       require("ak.config.editor.flash")
--     end,
--   }

--          ╭─────────────────────────────────────────────────────────╮
--          │                   See also: telescope                   │
--          ╰─────────────────────────────────────────────────────────╯

local Util = require("ak.util")

local opts = {
  search = {
    multi_window = true, -- default
  },
  label = {
    uppercase = true, --default
  },
  modes = {
    char = {
      enabled = false,
      -- multi_line = false,
      -- hide after jump when not using jump labels
      autohide = false, -- default
      -- show jump labels
      jump_labels = true, -- default
    },
  },
}

require("flash").setup(opts)
Util.register_referenced("flash.nvim")

local keys = vim.keymap.set
-- stylua: ignore start
keys({ "n", "x", "o" }, "s", function()
  require("flash").jump()
end, { desc = "Flash", silent = true })
keys({ "n", "x", "o" }, "S", function()
  require("flash").treesitter()
end, { desc = "Flash treesitter", silent = true })
keys("o", "r", function()
  require("flash").remote()
end, { desc = "Remote flash", silent = true })
keys({ "o", "x" }, "R", function()
  require("flash").flash_treesitter_search()
end, { desc = "Treesitter search", silent = true })
keys("c", "<c-s>", function()
  require("flash").toggle() -- in command mode
end, { desc = "Treesitter flash search", silent = true })
-- stylua: ignore end
