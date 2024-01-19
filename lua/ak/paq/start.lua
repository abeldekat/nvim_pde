local Util = require("ak.util")
local M = {}
local Color = require("ak.color")

local start_spec = {
  "savq/paq-nvim",
  "nvim-lua/plenary.nvim",
  "ThePrimeagen/harpoon",
}

function M.spec()
  Util.paq.setup()
  return start_spec
end

function M.setup()
  require("ak.config.options")
  require("ak.config.autocmds")
  require("ak.config.keymaps")

  vim.cmd.packadd("colors_" .. Color.color)
  require("ak.config.colors." .. Color.color)
  vim.cmd.colorscheme(Color.color)

  require("ak.config.harpoon_one")
end

return M
