local autoload = false

return {
  "echasnovski/mini.clue",
  event = function()
    return autoload and { "VeryLazy" } or {}
  end,
  keys = function()
    return autoload and {}
      or {
        {
          "<leader>uk",
          function()
            require("mini.clue")
          end,
          desc = "Activate mini.clue",
        },
      }
  end,
  config = function()
    local miniclue = require("mini.clue")

    local opts = {
      window = {
        config = { width = "auto" },
        -- delay = 0,
      },

      triggers = {
        -- not encouraged:
        -- { mode = "o", keys = "i" },
        -- { mode = "o", keys = "a" },

        -- -- `[` key
        -- { mode = "n", keys = "[" },
        -- { mode = "x", keys = "[" },
        -- --
        -- -- `]` key
        -- { mode = "n", keys = "]" },
        -- { mode = "x", keys = "]" },

        -- Leader triggers
        { mode = "n", keys = "<Leader>" },
        { mode = "x", keys = "<Leader>" },

        -- Built-in completion
        { mode = "i", keys = "<C-x>" },

        -- `g` key
        { mode = "n", keys = "g" },
        { mode = "x", keys = "g" },

        -- Marks
        { mode = "n", keys = "'" },
        { mode = "n", keys = "`" },
        { mode = "x", keys = "'" },
        { mode = "x", keys = "`" },

        -- Registers
        { mode = "n", keys = '"' },
        { mode = "x", keys = '"' },
        { mode = "i", keys = "<C-r>" },
        { mode = "c", keys = "<C-r>" },

        -- Window commands
        { mode = "n", keys = "<C-w>" },

        -- `z` key
        { mode = "n", keys = "z" },
        { mode = "x", keys = "z" },
      },

      clues = { -- clues for triggers...

        { mode = "n", keys = "<leader><tab>", desc = "+tabs" },
        { mode = "n", keys = "<leader>c", desc = "+code" },
        { mode = "n", keys = "<leader>d", desc = "+debug" },
        { mode = "n", keys = "<leader>f", desc = "+file/find" },
        { mode = "n", keys = "<leader>g", desc = "+git" },
        { mode = "n", keys = "<leader>gh", desc = "+hunks" },
        { mode = "n", keys = "<leader>m", desc = "+misc" },
        { mode = "n", keys = "<leader>s", desc = "+search" },
        { mode = "n", keys = "<leader>t", desc = "+test" },
        { mode = "n", keys = "<leader>u", desc = "+ui" },
        { mode = "n", keys = "<leader>x", desc = "+diagnostics/quickfix" },

        miniclue.gen_clues.builtin_completion(),
        miniclue.gen_clues.g(),
        miniclue.gen_clues.marks(),
        -- miniclue.gen_clues.registers({ show_contents = false }),
        miniclue.gen_clues.registers(),
        miniclue.gen_clues.windows(),
        miniclue.gen_clues.z(),
      },
    }

    require("mini.clue").setup(opts)
  end,
}

-- which-key helps you remember key bindings by showing a popup
-- with the active keybindings of the command you started typing.
-- return {
--   "folke/which-key.nvim",
--   event = function()
--     return autoload and { "VeryLazy" } or {}
--   end,
--   keys = function()
--     return autoload and {}
--       or {
--         {
--           "<leader>uk",
--           function()
--             require("which-key")
--           end,
--           desc = "Activate Which-key",
--         },
--       }
--   end,
--   config = function()
--     local opts = {
--       plugins = { spelling = true },
--       defaults = {
--         mode = { "n", "v" },
--         ["g"] = { name = "+goto" },
--         ["]"] = { name = "+next" },
--         ["["] = { name = "+prev" },
--         ["<leader><tab>"] = { name = "+tabs" },
--         ["<leader>c"] = { name = "+code" },
--         ["<leader>d"] = { name = "+debug" },
--         ["<leader>f"] = { name = "+file/find" },
--         ["<leader>g"] = { name = "+git" },
--         ["<leader>gh"] = { name = "+hunks" },
--         ["<leader>m"] = { name = "+misc" },
--         ["<leader>s"] = { name = "+search" },
--         ["<leader>t"] = { name = "+test" },
--         ["<leader>u"] = { name = "+ui" },
--         ["<leader>x"] = { name = "+diagnostics/quickfix" },
--       },
--     }
--     local wk = require("which-key")
--     wk.setup(opts)
--     wk.register(opts.defaults)
--   end,
-- }
