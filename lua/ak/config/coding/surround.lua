--          ╭─────────────────────────────────────────────────────────╮
--          │          DEPRECATED in favor of mini.surround           │
--          ╰─────────────────────────────────────────────────────────╯

--          ╭─────────────────────────────────────────────────────────╮
--          │                          deps:                          │
--          ╰─────────────────────────────────────────────────────────╯
-- add("kylechui/nvim-surround")
-- require("ak.config.coding.surround")

--          ╭─────────────────────────────────────────────────────────╮
--          │                          lazy:                          │
--          ╰─────────────────────────────────────────────────────────╯
-- {
--     "kylechui/nvim-surround",
--     version = "*",
--     event = "VeryLazy",
--     config = function()
--       require("ak.config.coding.surround")
--     end,
--   }

--          ╭─────────────────────────────────────────────────────────╮
--          │             The plugin creates the mappings             │
--          │                                                         │
--          │  { "<C-g>z", desc = "Add a surrounding pair around the  │
--          │        cursor (insert mode)", mode = { "i" } },         │
--          │                       insert_line                       │
--          │  { "<C-g>Z", desc = "Add a surrounding pair around the  │
--          │ cursor, on new lines (insert mode)", mode = { "i" } },  │
--          │                         normal                          │
--          │ { "yz", desc = "Add a surrounding pair around a motion  │
--          │                    (normal mode)" },                    │
--          │                       normal_cur                        │
--          │   { "yzz", desc = "Add a surrounding pair around the    │
--          │             current line (normal mode)" },              │
--          │                       normal_line                       │
--          │     { "yZ", desc = "Add a surrounding pair around a     │
--          │         motion, on new lines (normal mode)" },          │
--          │                     normal_cur_line                     │
--          │   { "yZZ", desc = "Add a surrounding pair around the    │
--          │      current line, on new lines (normal mode)" },       │
--          │                         visual                          │
--          │  { "Z", desc = "Add a surrounding pair around a visual  │
--          │              selection", mode = { "x" } },              │
--          │                       visual_line                       │
--          │ { "gZ", desc = "Add a surrounding pair around a visual  │
--          │       selection, on new lines", mode = { "x" } },       │
--          │                         change                          │
--          │      { "dz", desc = "Delete a surrounding pair" },      │
--          │                         delete                          │
--          │      { "cz", desc = "Change a surrounding pair" },      │
--          │    { "cZ", desc = "Change a surrounding pair, on new    │
--          │                        lines" },                        │
--          ╰─────────────────────────────────────────────────────────╯

---@diagnostic disable-next-line: missing-fields
require("nvim-surround").setup({
  -- key to capital means: "surrounding pair on new line"

  -- insert: pairs-like behavior. Surround with any char
  -- indent_lines = false
  -- move_cursor = false
  keymaps = {
    insert = "<C-g>z",
    insert_line = "<C-g>Z",
    normal = "yz",
    normal_cur = "yzz",
    normal_line = "yZ",
    normal_cur_line = "yZZ",
    visual = "Z",
    visual_line = "gZ",
    delete = "dz",
    change = "cz",
    change_line = "cZ",
  },
})
