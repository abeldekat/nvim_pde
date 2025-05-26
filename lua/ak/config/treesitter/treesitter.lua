-- The query editor can be opened by pressing o in the :InspectTree window,
-- with the :EditQuery command, or by calling vim.treesitter.query.edit() directly.

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
}
require("nvim-treesitter.configs").setup(opts)
