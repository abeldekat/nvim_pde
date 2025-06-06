-- Replaces autopairs...
require("mini.pairs").setup({
  mappings = {
    -- Added < to neigh_pattern to disable single quote pair in rust lifetimes
    -- ["'"] = { action = 'closeopen', pair = "''", neigh_pattern = '[^%a\\].', register = { cr = false } },
    ["'"] = { action = "closeopen", pair = "''", neigh_pattern = "[^%a\\<].", register = { cr = false } },
  },
})
