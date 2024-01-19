local M = {}

local util_spec = {
  -- "folke/persistence.nvim",
  "dstein64/vim-startuptime",
  -- "jpalardy/vim-slime",
}

function M.spec()
  return util_spec
end

function M.setup()
  -- require("ak.config.persistence") -- event
  require("ak.config.startuptime") -- cmd
  -- require("ak.config.repl").init() -- keys
  -- require("ak.config.repl").setup()
end

return M
