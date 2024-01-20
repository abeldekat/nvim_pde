if vim.loader then
  vim.loader.enable()
end

-- Caching: Do all init in ak/init.lua
require("ak")({}, {}) -- extraspec, opts
