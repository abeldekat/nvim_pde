-- Also see: telescope-alternate

return {
  "nvim-neotest/neotest",
  keys = { { "<leader>tL", desc = "Load neotest" } },
  dependencies = {
    "nvim-neotest/nvim-nio",
  },
  config = function() require("ak.config.lang.testing") end,
}
