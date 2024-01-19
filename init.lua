if vim.loader then
  vim.loader.enable()
end

local opts = {
  dev_patterns = {},
  dev_path = "~/projects/lazydev",
  -- dev_path = "~/projects/clone",
}

-- Caching: Do all init in ak/init.lua
-- This init.lua is just an entry point
require("ak")({}, opts)
