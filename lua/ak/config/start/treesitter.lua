-- The query editor can be opened by pressing o in the :InspectTree window,
-- with the :EditQuery command, or by calling vim.treesitter.query.edit() directly.
--
-- Required: tree-sitter-cli, installed with pacman
-- See: SUPPORTED_LANGUAGES.md in nvim-treesitter repo
--
-- := vim.treesitter.highlighter.active

-- ron: rusty object notation, rasi: rofi, rst: python
-- stylua: ignore
local ensure_installed = { -- 44
  "awk", "bash", "bibtex", "c", "css", "diff",
  "git_config", "gitcommit", "git_rebase", "gitignore", "gitattributes", "go",
  "gomod", "gowork", "gosum", "html", "javascript", "jsdoc",
  "json", "jsonc", "json5", "lua", "luadoc", "luap",
  "make", "markdown", "markdown_inline", "ninja", "printf", "python",
  "query", "rasi", "regex", "ron", "rst", "rust",
  "sql", "toml", "tsx", "typescript", "vim", "vimdoc",
  "yaml", "xml",
}

-- local already_installed = require("nvim-treesitter.config").installed_parsers()
local isnt_installed = function(lang) return #vim.api.nvim_get_runtime_file("parser/" .. lang .. ".*", false) == 0 end
local to_install = vim.tbl_filter(isnt_installed, ensure_installed)

-- Parsers and queries can then be installed with:
if #to_install > 0 then require("nvim-treesitter").install(to_install) end

local group = vim.api.nvim_create_augroup("ak_treesitter", {})
local au = function(pattern, desc, callback)
  vim.api.nvim_create_autocmd("FileType", {
    desc = desc,
    pattern = pattern,
    group = group,
    callback = callback,
  })
end

-- For `nvim-treesitter` to support a specific feature for a specific language requires both a parser for that language
-- and an appropriate language-specific query file for that feature.
au(ensure_installed, "Treesitter Features", function(args) -- opt-in, based on parsers in ensure_installed
  -- Highlighting:
  vim.treesitter.start()
  -- if not pcall(vim.treesitter.start, bufnr) then return end -- or, if using "*" as pattern:

  -- Folds:
  -- vim.o.foldmethod = "expr"
  -- vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'

  -- Indentations, considered experimental
  -- local bufnr = args.buf
  -- local filetype = vim.bo[bufnr].filetype
  local filetype = args.match
  if filetype ~= "latex" then vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()" end

  -- Injections:
  -- Injections are used for multi-language documents, see `:h treesitter-language-injections`. No setup is needed.

  -- Locals:
  -- These queries can be used to look up definitions and references to identifiers in a given scope.
  -- They are not used in this plugin and are provided for (limited) backward compatibility.
end)
