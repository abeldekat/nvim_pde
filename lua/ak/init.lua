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
  if vim.env.USE_LAZY then
    require("ak.boot.lazy")(extraspec, opts)
  else
    require("ak.boot.paq")()
  end
end
