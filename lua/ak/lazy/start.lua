local Util = require("ak.util")
local did_init = false
local group = vim.api.nvim_create_augroup("lazy_ak", { clear = true })

local function load(mod)
  Util.try(function() require(mod) end, { msg = "Failed loading " .. mod })
end

vim.api.nvim_create_autocmd("User", {
  --          ╭─────────────────────────────────────────────────────────╮
  --          │   When VeryLazy fires, this autocmd is executed first   │
  --          ╰─────────────────────────────────────────────────────────╯
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
      load("ak.config.autocmds") -- Could also load on VeryLazy(dashboard)

      -- No priorities needed on the various colorschemes:
      Util.try(function() vim.cmd.colorscheme(require("ak.color").color) end, {
        msg = "Could not load your colorscheme",
        on_error = function(msg) Util.error(msg) end,
      })

      -- Close the lazy ui(install/update) on VimEnter:
      -- In LazyVim, this is done in the config of the dashboard
      -- Note: lazy.nvim creates an autocmd on VimEnter,
      -- in lazy.view.float, method M:focus()
      vim.api.nvim_create_autocmd("VimEnter", {
        group = "lazy_ak",
        callback = function()
          if vim.o.filetype == "lazy" then vim.cmd.close() end
        end,
      })
    end,
  },

  { "nvim-lua/plenary.nvim", lazy = true },
}
