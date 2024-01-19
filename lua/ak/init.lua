--          ╭─────────────────────────────────────────────────────────╮
--          │                 Separation of concerns                  │
--          │                                                         │
--          │                   The plugin manager:                   │
--          │                Retrieve and load plugins                │
--          │                       See ak.lazy                       │
--          │                       See ak.paq                        │
--          │                                                         │
--          │             The configution of the plugins:             │
--          │                      See ak.config                      │
--          ╰─────────────────────────────────────────────────────────╯

-- The lazy version is aliased: nviml="USE_LAZY=true NVIM_APPNAME=nviml nvim"
return function(extraspec, opts)
  if vim.env.USE_LAZY then
    require("ak.config.boot.lazy")(extraspec, opts)
  else
    require("ak.config.boot.paq")()
  end
end
