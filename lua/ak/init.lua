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
