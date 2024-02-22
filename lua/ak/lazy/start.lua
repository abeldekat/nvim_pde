local Util = require("ak.util")
local did_init = false

local function load(mod)
  Util.try(function() require(mod) end, { msg = "Failed loading " .. mod })
end

local group = vim.api.nvim_create_augroup("lazy_ak", { clear = true })

--          ╭─────────────────────────────────────────────────────────╮
--          │  When VeryLazy fires, the code below is executed first  │
--          │                Load autocmds and keymaps                │
--          ╰─────────────────────────────────────────────────────────╯
vim.api.nvim_create_autocmd("User", {
  group = group,
  pattern = "VeryLazy",
  callback = function()
    load("ak.config.keymaps")

    vim.api.nvim_create_user_command("LazyHealth", function()
      vim.cmd([[Lazy! load all]])
      vim.cmd([[checkhealth]])
    end, { desc = "Load all plugins and run :checkhealth" })

    vim.keymap.set("n", "<leader>l", "<cmd>Lazy<cr>", { desc = "Lazy", silent = true })
  end,
})

if did_init then return end
did_init = true
load("ak.config.options")

--          ╭─────────────────────────────────────────────────────────╮
--          │       LazyVim: On setup or on VeryLazy(dashboard)       │
--          ╰─────────────────────────────────────────────────────────╯
load("ak.config.autocmds")

return {
  { "folke/lazy.nvim", lazy = false, version = "*" },

  { -- mini.nvim is a good plugin to load on start
    -- the plugin does nothing when loaded
    -- each mini component needs to be activated separately
    "echasnovski/mini.nvim",
    priority = 10000,
    lazy = false,
    cond = true,
    config = function()
      -- Advantage: No priorities needed on the various colorschemes:
      Util.try(function() vim.cmd.colorscheme(require("ak.color").color) end, {
        msg = "Could not load your colorscheme",
        on_error = function(msg) Util.error(msg) end,
      })
    end,
  },

  { "nvim-lua/plenary.nvim", lazy = true },
}
