if vim.loader then
  vim.loader.enable()
end

local opts = {
  debug = false,

  dev_patterns = {},

  dev_path = "~/projects/lazydev",
  -- dev_path = "~/projects/clone",

  langs = { "markdown", "python" }, -- single point of lang control
}

-- Caching: Do all init in ak/init.lua
-- This init.lua is just an entry point
require("ak")({}, opts)
