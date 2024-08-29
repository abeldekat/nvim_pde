local Util = require("ak.util")
local miniclue = require("mini.clue")

local opts = {
  window = {
    config = { width = "auto" },
    -- delay = 2000, -- 1000
  },

  triggers = {
    -- Leader triggers
    { mode = "n", keys = "<Leader>" },
    { mode = "x", keys = "<Leader>" },

    -- Built-in completion
    { mode = "i", keys = "<C-x>" },

    -- `g` key
    { mode = "n", keys = "g" },
    { mode = "x", keys = "g" },

    -- Marks
    { mode = "n", keys = "'" },
    { mode = "n", keys = "`" },
    { mode = "x", keys = "'" },
    { mode = "x", keys = "`" },

    -- Registers
    { mode = "n", keys = '"' },
    { mode = "x", keys = '"' },
    { mode = "i", keys = "<C-r>" },
    { mode = "c", keys = "<C-r>" },

    -- Window commands
    { mode = "n", keys = "<C-w>" },

    -- `z` key
    { mode = "n", keys = "z" },
    { mode = "x", keys = "z" },
  },

  clues = { -- currently available: i, k, m, n, p, v, z
    { mode = "n", keys = "<leader><tab>", desc = "+tabs" },
    { mode = "n", keys = "<leader>c", desc = "+code" },
    { mode = "n", keys = "<leader>d", desc = "+debug" },
    { mode = "n", keys = "<leader>f", desc = "+fuzzy find" },
    { mode = "n", keys = "<leader>fo", desc = "+other pickers" },
    { mode = "n", keys = "<leader>g", desc = "+git" },
    { mode = "n", keys = "<leader>o", desc = "+other" },
    { mode = "n", keys = "<leader>s", desc = "+overseer" },
    { mode = "n", keys = "<leader>t", desc = "+test" },
    { mode = "n", keys = "<leader>u", desc = "+ui" },

    miniclue.gen_clues.builtin_completion(),
    miniclue.gen_clues.g(),
    miniclue.gen_clues.marks(),
    -- miniclue.gen_clues.registers({ show_contents = false }),
    miniclue.gen_clues.registers(),
    miniclue.gen_clues.windows(),
    miniclue.gen_clues.z(),
  },
}

local clue = require("mini.clue")
clue.setup(opts)
if not Util.opened_with_arguments() then
  -- clues on the dashboard:
  clue.enable_buf_triggers(vim.api.nvim_get_current_buf())
end
