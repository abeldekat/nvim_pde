--          ╭────────────────────────────────────────────────╮
--          │                   UI plugins                   │
--          ╰────────────────────────────────────────────────╯

local Util = require("ak.util")
vim.o.statusline = " " -- wait till statusline plugin is loaded

return {

  {
    "nvimdev/dashboard-nvim",
    event = function() return Util.opened_without_arguments() and "VimEnter" or {} end,
    config = function()
      require("ak.config.ui.dashboard").setup({
        {
          action = "Lazy",
          desc = " Lazy",
          icon = "󰒲 ",
          key = "l",
        },
      }, function()
        local stats = require("lazy").stats()
        local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)
        return { "⚡ Neovim loaded " .. stats.loaded .. "/" .. stats.count .. " plugins in " .. ms .. "ms" }
      end)
    end,
  },

  {
    "lukas-reineke/indent-blankline.nvim",
    event = "VeryLazy", -- event = lazyfile,
    config = function()
      require("ak.config.ui.indent_blankline")

      --          ╭─────────────────────────────────────────────────────────╮
      --          │  Efficiency: Also setup startup-plugin mini.statusline  │
      --          │          Mini.notify is used in ak.lazy.start           │
      --          ╰─────────────────────────────────────────────────────────╯
      require("ak.config.ui.mini_statusline")
    end,
  },

  {
    "stevearc/dressing.nvim",
    init = function()
      ---@diagnostic disable-next-line: duplicate-set-field
      vim.ui.select = function(...)
        require("lazy").load({ plugins = { "dressing.nvim" } })
        return vim.ui.select(...)
      end
      ---@diagnostic disable-next-line: duplicate-set-field
      vim.ui.input = function(...)
        require("lazy").load({ plugins = { "dressing.nvim" } })
        return vim.ui.input(...)
      end
    end,
  },
}
