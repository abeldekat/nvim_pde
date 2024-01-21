local Util = require("ak.util")
local M = {}

function M.spec()
  return { { "stevearc/conform.nvim", opt = true } }
end

function M.setup()
  Util.paq.on_events(function()
    require("ak.config.lang.formatting").init()
    vim.cmd.packadd("conform.nvim")
    require("ak.config.lang.formatting").setup()

    vim.defer_fn(function()
      vim.cmd("write")
    end, 500) -- the first write command has no effect...
  end, { "BufWritePre" })
end
return M
