-- See also: telescope

return {
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    vscode = true,
    -- stylua: ignore start
    keys = {
      { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash" },
      { "S", mode = { "n", "o", "x" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
      { "r", mode = "o", function() require("flash").remote() end, desc = "Remote Flash" },
      { "R", mode = { "o", "x" }, function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
      { "<c-s>", mode = { "c" }, function() require("flash").toggle() end, desc = "Toggle Flash Search" },
    },
    -- stylua: ignore end
    config = function()
      ---@type Flash.Config
      local opts = {
        search = {
          multi_window = true, -- default
        },
        label = {
          uppercase = true, --default
        },
        modes = {
          char = {
            enabled = false,
            -- multi_line = false,
            -- hide after jump when not using jump labels
            autohide = false, -- default
            -- show jump labels
            jump_labels = true, -- default
          },
        },
      }
      require("flash").setup(opts)
    end,
  },

  { -- disabled flash for fFtT
    "jinh0/eyeliner.nvim",
    event = "VeryLazy",
    config = function()
      require("eyeliner").setup({
        highlight_on_key = true, -- show highlights only after keypress
        dim = true, -- dim all other characters if set to true (recommended!)
      })
    end,
  },
}
