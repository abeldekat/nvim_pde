--          ╭─────────────────────────────────────────────────────────╮
--          │           Trying to adhere to the following:            │
--          │                   The plugin manager:                   │
--          │                manages the plugins(git)                 │
--          │                    loads the plugins                    │
--          │          does not contain plugin configuration          │
--          │                                                         │
--          │         All plugins are configured in ak.config         │
--          │                                                         │
--          │   Using this approach allows for switching to another   │
--          │                     plugin manager                      │
--          ╰─────────────────────────────────────────────────────────╯

return function(extraspec, opts)
  if vim.env.PCKR then -- experimenting...
    require("ak.config.options")
    require("ak.config.autocmds")
    require("ak.config.keymaps")
    require("ak.config.pckr")()
    pcall(vim.cmd.colorscheme, "tokyonight")
  else
    require("ak.config.lazy")(extraspec, opts)
  end
end
