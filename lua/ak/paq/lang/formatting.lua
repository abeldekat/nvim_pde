local Util = require("ak.util")
local M = {}

function M.spec()
  return { { "stevearc/conform.nvim", opt = true } }
end

function M.setup() -- previously in lazy.nvim: via init on verylazy
  Util.paq.on_events(function()
    require("ak.config.lang.formatting").init()
    vim.cmd.packadd("conform.nvim")
    require("ak.config.lang.formatting").setup()
  end, { "LspAttach", "BufWritePre" })
end
return M
