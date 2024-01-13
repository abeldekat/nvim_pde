--[[
Design:
Plenary acts as LazyVim placeholder to do options, autocommands, keymappings and colorscheme
Only one plugin fragment per spec --> specs don't need to be merged
No plugin.opts --> opts don't need to be merged
--]]
if vim.loader then
  vim.loader.enable()
end

local opts = { -- centralizing defaults subject to change
  debug = false,

  dev_patterns = {},
  -- dev_patterns = { "lazyflex" },

  dev_path = "~/projects/lazydev",
  -- dev_path = "~/projects/clone",

  flex = nil, -- require("misc.flex")({ use = false }), -- use flex=nil to not load the plugin
}
require("ak")({}, opts)
