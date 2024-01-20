-- Also see: telescope-alternate

local Util = require("ak.util")

local M = {}

function M.spec()
  return {
    { "nvim-neotest/neotest-python", opt = true },
    { "nvim-neotest/neotest", opt = true },
  }
end

function M.setup()
  Util.paq.on_keys(function()
    vim.cmd.packadd("neotest-python")
    vim.cmd.packadd("neotest")

    require("ak.config.lang.testing")
  end, "<leader>tL", "Load neotest")
end

return M
