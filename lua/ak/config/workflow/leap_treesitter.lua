-- Use leap only for its treesitter selection...

-- Treesitter incremental selection: Use S instead of suggested ga
-- Note: <C-Space> is used for tmux itself.
-- From the help:
-- Besides choosing a label (`ga{label}`), in Normal/Visual mode you can also use
-- the traversal keys for incremental selection (`;` and `,` are automatically
-- added to the default keys). The labels are forced to be safe, so you can
-- operate on the current selection right away (`ga;;y`).
-- **Tips**
-- * The traversal can "wrap around" backwards, so you can select the root node
--   right away (`ga,`), instead of going forward (`ga;;;...`).
local function treesitter() require("leap.treesitter").select() end
vim.keymap.set({ "n", "x", "o" }, "S", treesitter, { desc = "Leap treesitter" })
