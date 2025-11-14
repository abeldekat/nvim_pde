require("conform").setup({
  formatters_by_ft = {
    javascript = { "prettier" },
    json = { "prettier" },
    lua = { "stylua" },
    python = { "black" },
    r = { "air" },
  },
})
