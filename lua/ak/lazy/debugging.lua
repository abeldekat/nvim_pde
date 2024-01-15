--          ╭─────────────────────────────────────────────────────────╮
--          │     Lazy keys that are not overridden in the config     │
--          │          Example: <leader>uk, loads mini.clue.          │
--          │   Without this function, the keystrokes "uk" would be   │
--          │                        replayed                         │
--          ╰─────────────────────────────────────────────────────────╯
local function no_replay() end

-- dap: one key to load...
return {
  "mfussenegger/nvim-dap",
  dependencies = {
    "rcarriga/nvim-dap-ui",
    "theHamsta/nvim-dap-virtual-text",
    "jay-babu/mason-nvim-dap.nvim", -- dependencies = "mason.nvim",
    "mfussenegger/nvim-dap-python",
  },
  keys = { { "<leader>dL", no_replay, desc = "Load dap" } },
  config = function()
    require("ak.config.debugging")
  end,
}
