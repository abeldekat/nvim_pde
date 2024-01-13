return {
  {
    "numToStr/Comment.nvim",
    keys = {
      { "gc", mode = { "n", "v" }, desc = "Comment toggle linewise" },
      { "gb", mode = { "n", "v" }, desc = "Comment toggle blockwise" },
    },
    config = function()
      local commentstring_avail, commentstring = pcall(require, "ts_context_commentstring.integrations.comment_nvim")
      local opts = commentstring_avail and commentstring and { pre_hook = commentstring.create_pre_hook() } or {}
      require("Comment").setup(opts)
    end,
  },
  {
    "JoosepAlviste/nvim-ts-context-commentstring",
    lazy = true,
    config = function()
      ---@diagnostic disable-next-line: missing-fields
      require("ts_context_commentstring").setup({
        enable_autocmd = false,
      })
    end,
  },
}
