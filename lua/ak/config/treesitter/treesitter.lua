-- The query editor can be opened by pressing o in the :InspectTree window,
-- with the :EditQuery command, or by calling vim.treesitter.query.edit() directly.

---@type TSConfig
---@diagnostic disable-next-line: missing-fields
local opts = {
  highlight = { enable = true, disable = { "latex" } },
  indent = { enable = true },
  ensure_installed = {
    "bash",
    "bibtex",
    "c",
    "css",
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
    "go",
    "gomod",
    "gowork",
    "gosum",
  },
  -- If a function spans more than one page, leap's incremental selection
  -- cannot select outside the visible page...
  incremental_selection = {
    enable = true, -- using default keymaps gnn
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
}
require("nvim-treesitter.configs").setup(opts)
