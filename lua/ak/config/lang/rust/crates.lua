--          ╭─────────────────────────────────────────────────────────╮
--          │      A neovim plugin that helps managing crates.io      │
--          │                      dependencies.                      │
--          ╰─────────────────────────────────────────────────────────╯

-- local opts = { src = { cmp = { enabled = true }, }, }
-- https://github.com/Saecki/crates.nvim/pull/100 inline lsp
local opts = {
  lsp = {
    enabled = true,
    name = "crates.nvim",
    ---@diagnostic disable-next-line: unused-local
    on_attach = function(client, bufnr) end,
    actions = true,
    hover = true,
    completion = true,
  },
}
require("crates").setup(opts)
