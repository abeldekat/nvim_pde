local M = {}

function M.spec()
  return { "stevearc/conform.nvim" }
end

function M.setup()
  require("ak.config.lang.formatting").init() -- event
  require("ak.config.lang.formatting").setup()
end
return M
