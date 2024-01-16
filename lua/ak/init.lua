--          ╭─────────────────────────────────────────────────────────╮
--          │                 Separation of concerns                  │
--          │                                                         │
--          │                   The plugin manager:                   │
--          │                Retrieve and load plugins                │
--          │                       See ak.lazy                       │
--          │                                                         │
--          │             The configution of the plugins:             │
--          │                      See ak.config                      │
--          ╰─────────────────────────────────────────────────────────╯

return function(extraspec, opts)
  if vim.env.PAQ then -- experimenting
    require("ak.config.options")
    require("ak.config.autocmds")
    require("ak.config.keymaps")
    require("ak.config.boot.paq")()
    pcall(vim.cmd.colorscheme, "tokyonight")
  else
    require("ak.config.boot.lazy")(extraspec, opts)
  end
end
