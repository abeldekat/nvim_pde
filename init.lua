if vim.loader then
  vim.loader.enable()
end

-- Caching: Do all init in ak/init.lua
-- This init.lua is just an entry point
require("ak")({}, {}) -- extraspec, opts
