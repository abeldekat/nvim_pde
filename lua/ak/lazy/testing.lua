-- Also see: telescope-alternate

--          ╭─────────────────────────────────────────────────────────╮
--          │     Lazy keys that are not overridden in the config     │
--          │          Example: <leader>uk, loads mini.clue.          │
--          │   Without this function, the keystrokes "uk" would be   │
--          │                        replayed                         │
--          ╰─────────────────────────────────────────────────────────╯
local function no_replay() end

return {
  "nvim-neotest/neotest",
  keys = { { "<leader>tL", no_replay, desc = "Load neotest" } },
  dependencies = {
    "nvim-neotest/neotest-python",
  },
  config = function()
    require("ak.config.testing")
  end,
}
