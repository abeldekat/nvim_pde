return {
  "mfussenegger/nvim-dap",
  dependencies = {
    "rcarriga/nvim-dap-ui",
    "theHamsta/nvim-dap-virtual-text",
    "jay-babu/mason-nvim-dap.nvim", -- dependencies = "mason.nvim",
    "mfussenegger/nvim-dap-python",
  },
  keys = { { "<leader>dL", desc = "Load dap" } },
  config = function()
    require("ak.config.lang.debugging")
  end,
}
