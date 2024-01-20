local Util = require("ak.util")
local M = {}
local Color = require("ak.color")

local start_spec = {
  "savq/paq-nvim",
  "nvim-lua/plenary.nvim",
}

function M.spec()
  require("ak.config.options") -- leader key!
  -- Util.paq.setup() -- not needed
  return start_spec
end

function M.setup()
  require("ak.config.autocmds")
  require("ak.config.keymaps")

  Util.try(function()
    local name = Color.color
    -- nightfox has separate colorschemes:
    local name_or_nightfox = name:find("fox", 1, true) and "nightfox" or name

    vim.cmd.packadd("colors_" .. name_or_nightfox)
    require("ak.config.colors." .. name_or_nightfox)
    vim.cmd.colorscheme(name)
  end, {
    msg = "Could not load your colorscheme",
    on_error = function(msg)
      Util.error(msg)
      vim.cmd.colorscheme("habamax")
    end,
  })
end

return M
