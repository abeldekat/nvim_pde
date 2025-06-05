-- Cannot use gs and gS in both normal and visual mode because of mini.operators...
-- It is possible to use "gs" in operator pending mode though!

-- Jump2d discussion:
-- https://github.com/echasnovski/mini.nvim/discussions/1033#discussioncomment-10289232

-- Note: Leap also has a f across lines mode, like mini.jump.
-- Use s[some letter]enter. Very handy in for example MiniFiles explorer.

-- Flash:
-- The "s" is "anywhere" and the "S" is dedicated to treesitter selection.
-- Remote ("r") is only mapped in operator pending mode
-- Leap:
-- 1 Don't use anywhere, preserving autojump.
-- 2 Also use "r" in operator pending mode. Saving one character, good mnemonic.
-- 3 Also use "S" exclusively for treesitter. This is more inviting than "ga"(from example).

local leap = require("leap")
leap.opts.equivalence_classes = { " \t\r\n", "([{", ")]}", "'\"`" }

-- Mimic current setting of mini.jump2d:
leap.opts.safe_labels = "" -- no autojump
leap.opts.labels = "jkl;miosde"

local nxo = { "n", "x", "o" }
local nx = { "n", "x" }
local n = "n"
local o = "o"

-- Normal and visual mode: Bidirectional:
vim.keymap.set(nx, "s", "<Plug>(leap)", { desc = "Leap" })
-- Leap to other windows in normal mode, not used often:
-- Changed from S(now treesitter) to g/. Mnemonic: leap search
vim.keymap.set(n, "g/", "<Plug>(leap-from-window)", { desc = "Leap from window" })

-- Operator pending mode mappings are not bidirectional per recommendation:
vim.keymap.set(o, "s", "<Plug>(leap-forward)", { desc = "Leap forward" })
-- Changed form S(now treesitter) to gs.
vim.keymap.set(o, "gs", "<Plug>(leap-backward)", { desc = "Leap backward" })

-- Remote:
-- Examples yanking the paragraph at the position specified by `{leap}`:
-- `gl{leap}yap`,
-- `vgl{leap}apy`,
-- `yr{leap}ap` -- in operator pending mode, "r"(as used in flash) is shorter than "gl"
--
-- Example swapping two words:
-- `diwgl{leap}viwpP`
local function remote() require("leap.remote").action() end
vim.keymap.set(o, "r", remote, { desc = "Leap remote" })
-- Changed from gs/gS to gl, mnemonic for "go leap remote"
-- Surprisingly, gl is not used!
-- Note: cannot use gr: See mini.operators and lsp
vim.keymap.set(nx, "gl", remote, { desc = "Leap remote" })

-- Icing on the cake, no. 2 - automatic paste after yanking**
vim.api.nvim_create_augroup("LeapRemote", {})
vim.api.nvim_create_autocmd("User", {
  pattern = "RemoteOperationDone",
  group = "LeapRemote",
  callback = function(event)
    local expected_register = '"' -- not using system clipboard anymore...
    if vim.v.operator == "y" and event.data.register == expected_register then vim.cmd("normal! p") end
  end,
})

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
vim.keymap.set(nxo, "S", treesitter, { desc = "Leap treesitter" })

-- HACK: Temporarily override nvim_win_set_option to prevent leap from setting conceallevel to 0
-- NOTE: Both flash.nvim and mini.jump2d do not set the conceallevel...
-- Leap issues: 1 and 243
--
-- Leap sets conceallevel to 0, intending to prevent incorrect or impossible jumps.
-- As a consequence the text "shifts", especially in markdown and mini.files.
-- I favor an incidental "conceallevel" limitation over losing focus because of shifting text.
local nvim_win_set_option = vim.api.nvim_win_set_option -- NOTE: nvim_win_set_option is deprecated...
local no_conceal_on_leap_enter = function(window, name, value)
  if name == "conceallevel" then return end
  return nvim_win_set_option(window, name, value)
end
vim.api.nvim_create_autocmd("User", {
  group = vim.api.nvim_create_augroup("ak_leap", {}),
  pattern = "LeapEnter",
  callback = function()
    -- Triggers before leap sets the conceal level in its LeapEnter callback:
    vim.api.nvim_win_set_option = no_conceal_on_leap_enter

    -- Ensure the vim.api override is always restored.
    -- Triggers after leap has set the conceal level in its LeapEnter callback:
    vim.schedule(function() vim.api.nvim_win_set_option = nvim_win_set_option end)
  end,
})
