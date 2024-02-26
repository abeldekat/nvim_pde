--          ╭─────────────────────────────────────────────────────────╮
--          │                 Separation of concerns                  │
--          │                   The plugin section:                   │
--          │                Retrieve and load plugins                │
--          │                       See ak.boot                       │
--          │                                                         │
--          │                   The config section:                   │
--          │                        All setup                        │
--          │                      See ak.config                      │
--          ╰─────────────────────────────────────────────────────────╯

return function(opts)
  local plugin_manager = vim.env.AK_BOOT

  if plugin_manager == "lazy" then
    require("ak.boot.lazy")(opts)
  else
    require("ak.boot.deps")(opts)
  end
end
