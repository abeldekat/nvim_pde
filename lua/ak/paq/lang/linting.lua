local Util = require("ak.util")
local M = {}

local function lazyfile()
  return { "BufReadPost", "BufNewFile", "BufWritePre" }
end

function M.spec()
  return { { "mfussenegger/nvim-lint", opt = true } }
end

function M.setup()
  Util.paq.on_events(function()
    vim.cmd.packadd("nvim-lint")
    require("ak.config.lang.linting")
  end, lazyfile())
end
return M
