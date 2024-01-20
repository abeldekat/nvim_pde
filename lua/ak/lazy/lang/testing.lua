-- Also see: telescope-alternate
return {
  "nvim-neotest/neotest",
  keys = { { "<leader>tL", desc = "Load neotest" } },
  dependencies = {
    "nvim-neotest/neotest-python",
  },
  config = function()
    require("ak.config.lang.testing")
  end,
}
