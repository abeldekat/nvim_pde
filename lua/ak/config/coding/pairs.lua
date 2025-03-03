-- Replaces autopairs...

local pairs = require("mini.pairs")
local opts = {
  mappings = {

    -- Added < to neigh_pattern to disable single quote pair in rust lifetimes
    -- ["'"] = { action = 'closeopen', pair = "''", neigh_pattern = '[^%a\\].', register = { cr = false } },
    ["'"] = { action = "closeopen", pair = "''", neigh_pattern = "[^%a\\<].", register = { cr = false } },
  },
}
pairs.setup(opts)
