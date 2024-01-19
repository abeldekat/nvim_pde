-- Also see: telescope-alternate
local function no_replay() end

return {
  "nvim-neotest/neotest",
  keys = { { "<leader>tL", no_replay, desc = "Load neotest" } },
  dependencies = {
    "nvim-neotest/neotest-python",
  },
  config = function()
    require("ak.config.lang.testing")
  end,
}
