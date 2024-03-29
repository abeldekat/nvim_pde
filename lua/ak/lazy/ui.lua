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

  {
    "lukas-reineke/indent-blankline.nvim",
    event = "VeryLazy",
    config = function()
      --          ╭─────────────────────────────────────────────────────────╮
      --          │  Efficiency: Also setup startup-plugin mini.statusline  │
      --          │          Mini.notify is used in ak.lazy.start           │
      --          ╰─────────────────────────────────────────────────────────╯
      -- require("ak.config.ui.mini_statusline")

      require("ak.config.ui.indent_blankline")
    end,
  },

  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    --   dependencies = { "abeldekat/harpoonline", version = "*" },
    dependencies = { "abeldekat/grappleline", version = "*" },
    init = function()
      vim.g.lualine_laststatus = vim.o.laststatus
      if vim.fn.argc(-1) > 0 then
        -- set an empty statusline till lualine loads
        vim.o.statusline = " "
      else
        -- hide the statusline on the starter page
        vim.o.laststatus = 0
      end
    end,
    config = function()
      -- local on_update = function() vim.wo.statusline = "%!v:lua.MiniStatusline.active()" end
      local on_update = function() require("lualine").refresh() end
      --          ╭─────────────────────────────────────────────────────────╮
      --          │                    Default lualine_b                    │
      --          ╰─────────────────────────────────────────────────────────╯
      -- local lualine_b = { 'branch', 'diff', 'diagnostics' }
      --          ╭─────────────────────────────────────────────────────────╮
      --          │                    Using harpoonline                    │
      --          ╰─────────────────────────────────────────────────────────╯
      -- require("ak.config.ui.harpoonline").setup(on_update)
      -- local lualine_b = { require("harpoonline").format, "branch", "diff", "diagnostics" }
      --          ╭─────────────────────────────────────────────────────────╮
      --          │                  Using grapple builtin                  │
      --          ╰─────────────────────────────────────────────────────────╯
      -- local lualine_b = { "grapple", "branch", "diff", "diagnostics" } -- first grapple example
      -- local lualine_b = {
      --   {
      --     function() return require("grapple").name_or_index() end,
      --     cond = require("grapple").exists,
      --   },
      --   "branch",
      --   "diff",
      --   "diagnostics",
      -- } -- second grapple example
      --          ╭─────────────────────────────────────────────────────────╮
      --          │                    Using grappleline                    │
      --          ╰─────────────────────────────────────────────────────────╯
      require("ak.config.ui.grappleline").setup(on_update)
      local lualine_b = { require("grappleline").format, "branch", "diff", "diagnostics" }

      require("lualine").setup({
        options = {
          theme = "auto",
          globalstatus = true,
          disabled_filetypes = { statusline = { "dashboard", "alpha", "starter" } },
        },
        sections = {
          lualine_b = lualine_b,
        },
      })
    end,
  },
}
