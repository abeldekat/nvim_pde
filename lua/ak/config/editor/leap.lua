-- Cannot use gs and gS because of mini.operators...

-- Jump2d discussion:
-- https://github.com/echasnovski/mini.nvim/discussions/1033#discussioncomment-10289232

-- Flash:
-- The "s" is "anywhere" and the "S" is dedicated to treesitter.
-- Remote ("r") is only mapped in operator pending mode

require("leap").opts.equivalence_classes = { " \t\r\n", "([{", ")]}", "'\"`" }

local nxo = { "n", "x", "o" }
local nx = { "n", "x" }
local n = "n"
local o = "o"

-- Bidirectional in normal and visual mode:
vim.keymap.set(nx, "s", "<Plug>(leap)", { desc = "Leap" })
-- Leap to other windows, only defined in normal mode:
vim.keymap.set(n, "S", "<Plug>(leap-from-window)", { desc = "Leap from window" })
-- Per recommendation, not bidirectional in operator pending mode:
vim.keymap.set(o, "s", "<Plug>(leap-forward)", { desc = "Leap forward" })
vim.keymap.set(o, "S", "<Plug>(leap-backward)", { desc = "Leap backward" })

-- Remote:
-- Examples yanking the paragraph at the position specified by `{leap}`:
-- `g/{leap}yap`,
-- `vg/{leap}apy`,
-- `yg/{leap}ap`,
-- `yr{leap}ap` -- in operator pending mode, "r"(as used in flash) is shorter than "g/"
--
-- Example swapping two words:
-- `diwg/{leap}viwpP`
--
local function remote() require("leap.remote").action() end
vim.keymap.set(nxo, "g/", remote, { desc = "Leap remote" })
-- Prefer this mapping, thus using remote in operator pending mode:
vim.keymap.set(o, "r", remote, { desc = "Leap remote" })

-- Icing on the cake, no. 2 - automatic paste after yanking**
vim.api.nvim_create_augroup("LeapRemote", {})
vim.api.nvim_create_autocmd("User", {
  pattern = "RemoteOperationDone",
  group = "LeapRemote",
  callback = function(event)
    local expected_register = "+" -- "-"
    if vim.v.operator == "y" and event.data.register == expected_register then vim.cmd("normal! p") end
  end,
})

-- Treesitter incremental selection:
-- <C-Space> is used for tmux
-- Using "Z" instead of the suggested "ga" in the example
-- "Z" is easier to type and almost next to "s"
--
-- From the help:
--
-- Besides choosing a label (`ga{label}`), in Normal/Visual mode you can also use
-- the traversal keys for incremental selection (`;` and `,` are automatically
-- added to the default keys). The labels are forced to be safe, so you can
-- operate on the current selection right away (`ga;;y`).
--
-- **Tips**
-- * The traversal can "wrap around" backwards, so you can select the root node
--   right away (`ga,`), instead of going forward (`ga;;;...`).
local function treesitter() require("leap.treesitter").select() end
vim.keymap.set(nxo, "Z", treesitter, { desc = "Leap treesitter" })
