-- Also see: telescope-alternate

local Util = require("ak.util")
local add, later = vim.cmd.packadd, Util.submodules.later

later(function()
  local sources = {
    "neotest-python",
    "neotest",
  }
  Util.defer.on_keys(function()
    for _, source in ipairs(sources) do
      add(source)
    end
    require("ak.config.lang.testing")
  end, "<leader>tL", "Load neotest")
end)
