local which_key_autoload = false

-- which-key helps you remember key bindings by showing a popup
-- with the active keybindings of the command you started typing.
return {
  "folke/which-key.nvim",
  event = function()
    return which_key_autoload and { "VeryLazy" } or {}
  end,
  keys = function()
    return which_key_autoload and {}
      or {
        {
          "<leader>uk",
          function()
            require("which-key")
          end,
          desc = "Activate Which-key",
        },
      }
  end,
  config = function()
    local opts = {
      plugins = { spelling = true },
      defaults = {
        mode = { "n", "v" },
        ["g"] = { name = "+goto" },
        ["]"] = { name = "+next" },
        ["["] = { name = "+prev" },
        ["<leader><tab>"] = { name = "+tabs" },
        ["<leader>c"] = { name = "+code" },
        ["<leader>d"] = { name = "+debug" },
        ["<leader>f"] = { name = "+file/find" },
        ["<leader>g"] = { name = "+git" },
        ["<leader>gh"] = { name = "+hunks" },
        ["<leader>m"] = { name = "+misc" },
        ["<leader>s"] = { name = "+search" },
        ["<leader>t"] = { name = "+test" },
        ["<leader>u"] = { name = "+ui" },
        ["<leader>x"] = { name = "+diagnostics/quickfix" },
      },
    }
    local wk = require("which-key")
    wk.setup(opts)
    wk.register(opts.defaults)
  end,
}
