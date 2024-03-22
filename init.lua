if vim.loader then vim.loader.enable() end
vim.uv = vim.uv or vim.loop -- shim: on 0.9.5, use vim.loop

-- Caching: Do all init in ak/init.lua
require("ak")({}) -- opts
