-- "lukas-reineke/indent-blankline.nvim". Replaced by mini.indent_scope...
local opts = {
  indent = {
    char = "│",
    tab_char = "│",
  },
  scope = {
    enabled = true,
    show_start = false,
    show_end = false,
    include = {
      node_type = { lua = { "return_statement", "table_constructor" } },
    },
  },
  -- scope = { enabled = false },
  exclude = {
    filetypes = {
      "help",
      "starter",
      "mason",
      "toggleterm",
    },
  },
}
require("ibl").setup(opts)
