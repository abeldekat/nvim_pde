-- Also see: telescope-alternate
-- local function no_replay() end
-- keys = { { "<leader>tL", no_replay, desc = "Load neotest" } },

local M = {}

function M.spec()
  return {
    { "nvim-neotest/neotest-python", opt = true },
    { "nvim-neotest/neotest", opt = true },
  }
end

function M.setup()
  -- require("ak.config.lang.testing")
end

return M
