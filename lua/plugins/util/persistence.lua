return {
  "folke/persistence.nvim",
  event = "BufReadPre",
  keys = {
    {
      "<leader>ms",
      function()
        require("persistence").load()
      end,
      desc = "Restore session",
    },
    {
      "<leader>mL",
      function()
        require("persistence").load({ last = true })
      end,
      desc = "Restore last session",
    },
    {
      "<leader>mD",
      function()
        require("persistence").stop()
      end,
      desc = "Don't save current session",
    },
  },
  config = function()
    require("persistence").setup({ options = vim.opt.sessionoptions:get() })
  end,
}
