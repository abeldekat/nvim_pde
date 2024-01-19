local M = {}

function M.spec()
  return { "mfussenegger/nvim-lint" }
end

function M.setup()
  require("ak.config.lang.linting") -- event
end
return M
