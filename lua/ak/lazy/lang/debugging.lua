return {
  "mfussenegger/nvim-dap",
  dependencies = {
    "jay-babu/mason-nvim-dap.nvim", -- dependencies = "mason.nvim",
    "nvim-neotest/nvim-nio", -- dependency for dap ui
    "rcarriga/nvim-dap-ui",
    "mfussenegger/nvim-dap-python",
    "theHamsta/nvim-dap-virtual-text",
    "jbyuki/one-small-step-for-vimkind", -- lua
  },
  keys = { { "<leader>dL", desc = "Load dap" } },
  config = function() require("ak.config.lang.debugging") end,
}
