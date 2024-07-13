--          ╭─────────────────────────────────────────────────────────╮
--          │                 Separation of concerns                  │
--          │                   The package manager:                  │
--          │                Retrieve and load plugins                │
--          │                      See ak.deps                        │
--          │                                                         │
--          │                   The config section:                   │
--          │                        All setup                        │
--          │                      See ak.config                      │
--          ╰─────────────────────────────────────────────────────────╯

return function(opts)
  -- local plugin_manager = vim.env.AK_BOOT -- only mini.deps...
  require("ak.mini_deps")(opts)
end
