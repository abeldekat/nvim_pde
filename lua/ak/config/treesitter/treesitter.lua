--          ╭─────────────────────────────────────────────────────────╮
--          │             The following keys are created:             │
--          │                                                         │
--          │     { "<c-space>", desc = "Increment selection" },      │
--          │  { "<bs>", desc = "Decrement selection", mode = "x" },  │
--          │                                                         │
--          ╰─────────────────────────────────────────────────────────╯

-- The query editor can be opened by pressing o in the :InspectTree window,
-- with the :EditQuery command, or by calling vim.treesitter.query.edit() directly.

---@type TSConfig
---@diagnostic disable-next-line: missing-fields
local opts = {
  highlight = { enable = true },
  indent = { enable = true },
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
    -- Normal mode:
    -- gnn : "Start selecting [n]odes with [n]vim treesitter"
    -- Visual mode, contextual:
    -- grn : "Inc[r]ement selection to named [n]ode"
    -- grm : "Sh[r]ink selection to previous named node" (m is next to n on keyboard)
    -- grc : "Inc[r]ement selection to surrounding s[c]ope"
    --
    -- keymaps = { -- "C-space" is not usable in tmux...
    --   init_selection = "<C-space>", -- gnn
    --   node_incremental = "<C-space>", -- grn
    --   scope_incremental = false, -- grc
    --   node_decremental = "<bs>", -- grm
    -- },
  },

  -- init_selection = "gts",
  -- node_incremental = "gni",
  -- scope_incremental = "gsi",
  -- node_decremental = "gdi",
}
require("nvim-treesitter.configs").setup(opts)
