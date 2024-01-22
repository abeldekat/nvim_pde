--          ╭─────────────────────────────────────────────────────────╮
--          │                 Separation of concerns                  │
--          │                   The plugin section:                   │
--          │                Retrieve and load plugins                │
--          │              See ak.boot [ak.paq, ak.lazy]              │
--          │                                                         │
--          │                   The config section:                   │
--          │                        All setup                        │
--          │                      See ak.config                      │
--          ╰─────────────────────────────────────────────────────────╯

return function(extraspec, opts)
  local plugin_manager = vim.env.AK_BOOT

  if plugin_manager == "lazy" then
    require("ak.boot.lazy")(extraspec, opts)
  else
    require("ak.boot.paq")()
  end
end
