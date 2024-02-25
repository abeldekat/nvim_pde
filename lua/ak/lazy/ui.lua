--          ╭────────────────────────────────────────────────╮
--          │                   UI plugins                   │
--          ╰────────────────────────────────────────────────╯

local Util = require("ak.util")
vim.o.statusline = " " -- wait till statusline plugin is loaded

local function load_mini_starter()
  require("ak.config.ui.mini_starter").setup({
    {
      action = "Lazy",
      name = "Lazy",
      section = "Lazy",
    },
  }, function()
    local stats = require("lazy").stats()
    local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)
    local menu_clue = "Press space for the menu"
    local lazy_report = string.format("Neovim loaded %s/%s plugins in %sms", stats.loaded, stats.count, ms)
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
