return {
  {
    "LudoPinelli/comment-box.nvim",
    keys = {
      { "<leader>Cb", mode = "v" },
      { "<leader>Cl", mode = "v" },
    },
    config = function()
      require("lua.ak.config.comment_box")
    end,
  },
  {
    "numToStr/Comment.nvim", -- the plugin creates the gc and gb mappings
    keys = {
      { "gc", mode = { "n", "v" } },
      { "gb", mode = { "n", "v" } },
    },
    dependencies = { "JoosepAlviste/nvim-ts-context-commentstring" },
    config = function()
      require("ak.config.comment")
    end,
  },
}
