--          ╭────────────────────────────────────────────────╮
--          │                   UI plugins                   │
--          ╰────────────────────────────────────────────────╯

local Util = require("ak.util")
vim.o.statusline = " " -- wait till statusline plugin is loaded

local function load_mini_starter()
  require("ak.config.ui.mini_starter").setup({
    {
      action = "Lazy",
      name = "1. Lazy",
      section = "Lazy",
    },
  }, function()
    local stats = require("lazy").stats()
    local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)
    local lazy_report = string.format("⚡ Neovim loaded %s/%s plugins in %sms", stats.loaded, stats.count, ms)
    local menu_clue = "  Press space for the menu"
    return string.format("%s\n%s", lazy_report, menu_clue)
  end)
end

if Util.opened_without_arguments() then
  vim.api.nvim_create_autocmd("VimEnter", {
    group = vim.api.nvim_create_augroup("ak_mini_starter", { clear = true }),
    once = true,
    callback = load_mini_starter,
  })
end

return {

  -- { "abeldekat/harpoonline", version = "*" },

  {
    "lukas-reineke/indent-blankline.nvim",
    event = "VeryLazy",
    config = function()
      --          ╭─────────────────────────────────────────────────────────╮
      --          │  Efficiency: Also setup startup-plugin mini.statusline  │
      --          │          Mini.notify is used in ak.lazy.start           │
      --          ╰─────────────────────────────────────────────────────────╯
      require("ak.config.ui.mini_statusline")

      require("ak.config.ui.indent_blankline")
    end,
  },

  -- {
  --   "nvim-lualine/lualine.nvim",
  --   event = "VeryLazy",
  --   -- dependencies = { "letieu/harpoon-lualine" },
  --   init = function()
  --     vim.g.lualine_laststatus = vim.o.laststatus
  --     if vim.fn.argc(-1) > 0 then
  --       -- set an empty statusline till lualine loads
  --       vim.o.statusline = " "
  --     else
  --       -- hide the statusline on the starter page
  --       vim.o.laststatus = 0
  --     end
  --   end,
  --   config = function()
  --     local Harpoonline = require("harpoonline")
  --     Harpoonline.setup({ on_update = function() require("lualine").refresh() end })
  --     local lualine_c = { Harpoonline.format, "filename" }
  --
  --     -- local lualine_c = { "harpoon2", "filename" }
  --     require("lualine").setup({
  --       options = {
  --         theme = "auto",
  --         globalstatus = true,
  --         disabled_filetypes = { statusline = { "dashboard", "alpha", "starter" } },
  --       },
  --       sections = {
  --         lualine_c = lualine_c,
  --       },
  --     })
  --   end,
  -- },
}
