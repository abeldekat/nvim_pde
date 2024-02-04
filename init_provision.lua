if vim.loader then
  vim.loader.enable()
end

vim.g.ak_provisioning = true
require("ak.boot.submodules")({}) -- opts

vim.cmd("quit")
