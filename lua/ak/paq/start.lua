local M = {}

function M.spec()
  require("ak.config.options")
  require("ak.config.autocmds")
  require("ak.config.keymaps")

  local result = require("ak.paq.colors").spec()
  table.insert(result, "savq/paq-nvim")
  table.insert(result, "nvim-lua/plenary.nvim")
  return result
end

function M.setup()
  require("ak.paq.colors").colorscheme()
end

return M
