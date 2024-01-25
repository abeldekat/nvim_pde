local Util = require("ak.util")
local M = {}

local util_spec = {
  -- { "folke/persistence.nvim", opt = true },
  { "dstein64/vim-startuptime", opt = true },
  { "jpalardy/vim-slime", opt = true },
}

function M.spec()
  return util_spec
end

function M.setup()
  Util.defer.on_keys(function()
    vim.cmd.packadd("vim-startuptime")
    require("ak.config.startuptime")
  end, "<leader>ms", "StartupTime")

  Util.defer.on_keys(function()
    vim.cmd.packadd("vim-slime")
    require("ak.config.repl")
  end, "<leader>mr", "Repl")

  -- Util.defer.on_events(function()
  --   vim.cmd.packadd("persistence.nvim")
  --   require("ak.config.persistence")
  -- end, "BufReadPre")
end

return M
