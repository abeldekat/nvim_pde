if vim.loader then
  vim.loader.enable()
end

local opts = {
  debug = false,

  dev_patterns = {},
  -- dev_patterns = { "lazyflex" },

  dev_path = "~/projects/lazydev",
  -- dev_path = "~/projects/clone",

  flex = nil, -- require("misc.flex")({ use = false }), -- use flex=nil to not load the plugin
}

-- Caching: Do all init in ak/init.lua
-- This init.lua is just an entry point
require("ak")({}, opts)
