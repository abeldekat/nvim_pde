local Util = require("ak.util")
local add, later = vim.cmd.packadd, Util.submodules.later

later(function()
  local sources = {
    "mason-nvim-dap.nvim",
    "nvim-dap-ui",
    "nvim-dap-virtual-text",
    "nvim-dap-python",
    "nvim-dap",
  }

  Util.defer.on_keys(function()
    for _, source in ipairs(sources) do
      add(source)
    end
    require("ak.config.lang.debugging")
  end, "<leader>dL", "Load dap")
end)
