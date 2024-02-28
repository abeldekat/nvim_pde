--          ╭─────────────────────────────────────────────────────────╮
--          │        Favor this plugin over mini.indentscope          │
--          ╰─────────────────────────────────────────────────────────╯

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
      "dashboard",
      "starter",
      "Trouble",
      "trouble",
      "lazy",
      "mason",
      "toggleterm",
      "lazyterm",
    },
  },
}
require("ibl").setup(opts)
