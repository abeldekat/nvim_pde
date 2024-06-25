--          ╭─────────────────────────────────────────────────────────╮
--          │             The following keys are created:             │
--          │                                                         │
--          │     { "<c-space>", desc = "Increment selection" },      │
--          │  { "<bs>", desc = "Decrement selection", mode = "x" },  │
--          │                                                         │
--          ╰─────────────────────────────────────────────────────────╯

-- The query editor can be opened by pressing o in the :InspectTree window,
-- with the :EditQuery command, or by calling vim.treesitter.query.edit() directly.

local Util = require("ak.util")

local get_opts = function()
  ---@type TSConfig
  ---@diagnostic disable-next-line: missing-fields
  return {
    highlight = { enable = true },
    indent = { enable = true },
    sync_install = Util.is_headless(),
    ensure_installed = {
      "bash",
      "c",
      "diff",
      "html",
      "javascript",
      "jsdoc",
      "json",
      "jsonc",
      "lua",
      "luadoc",
      "luap",
      "make",
      "markdown",
      "markdown_inline",
      "printf",
      "python",
      "query",
      "regex",
      "toml", -- python
      "tsx",
      "typescript",
      "vim",
      "vimdoc",
      "yaml",
      -- Extra Langs:
      "awk",
      "git_config",
      "gitcommit",
      "git_rebase",
      "gitignore",
      "gitattributes",
      "ron", -- rusty object notation
      "rust",
      "sql",
      "xml",
      "json5", -- json
      "ninja", -- python
      "rst", -- python
      "rasi", -- rofi
    },
    incremental_selection = {
      enable = true,
      keymaps = {
        init_selection = "<C-space>",
        node_incremental = "<C-space>",
        scope_incremental = false,
        node_decremental = "<bs>",
      },
    },
  }
end

require("nvim-treesitter.configs").setup(get_opts())
