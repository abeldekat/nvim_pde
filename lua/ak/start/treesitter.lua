-- The query editor can be opened by pressing o in the :InspectTree window,
-- with the :EditQuery command, or by calling vim.treesitter.query.edit() directly.
--
-- Required: tree-sitter-cli, installed with pacman
-- See: SUPPORTED_LANGUAGES.md in nvim-treesitter repo
--
-- := vim.treesitter.highlighter.active

local M, H = {}, {}
M.setup = function()
  -- For `nvim-treesitter` to support a specific feature for a specific language both a parser for that language
  -- and an appropriate language-specific query file for that feature are required.
  vim.api.nvim_create_autocmd("FileType", { -- opt-in, based on parsers in H.ensure_installed
    desc = "Treesitter Features",
    pattern = H.ensure_installed,
    group = vim.api.nvim_create_augroup("ak_treesitter", {}),
    callback = H.on_filetype,
  })
end

M.install_or_update = function() -- install ensure_installed on first installation, update otherwise
  local ts = require("nvim-treesitter")
  local installed = ts.get_installed()
  if #installed == 0 then
    ts.install(H.ensure_installed, { summary = true })
  else
    vim.cmd("TSUpdate")
  end
end

-- ron: rusty object notation, rasi: rofi, rst: python
-- stylua: ignore
H.ensure_installed = { -- 45
  "awk", "bash", "bibtex", "c", "css", "diff",
  "fennel", "git_config", "gitcommit", "git_rebase", "gitignore", "gitattributes",
  "go", "gomod", "gowork", "gosum", "html", "javascript",
  "jsdoc", "json", "jsonc", "json5", "lua", "luadoc",
  "luap", "make", "markdown", "markdown_inline", "ninja", "printf",
  "python", "query", "rasi", "regex", "ron", "rst",
  "rust", "sql", "toml", "tsx", "typescript", "vim",
  "vimdoc", "yaml", "xml",
}

H.on_filetype = function(args)
  -- Highlighting, provided by Neovim:
  if not pcall(vim.treesitter.start) then -- instead of checking parsers on each startup...
    vim.notify("** Start installing treesitter parsers. Restart nvim when done! **", vim.log.levels.WARN)
    require("nvim-treesitter").install(H.ensure_installed, { summary = true })
    return
  end

  -- Indentations, considered experimental, provided by the plugin:
  if args.match ~= "latex" then vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()" end

  -- Folds:
  -- vim.o.foldmethod = "expr"
  -- vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
  -- Injections:
  -- Injections are used for multi-language documents, see `:h treesitter-language-injections`. No setup is needed.
  -- Locals:
  -- These queries can be used to look up definitions and references to identifiers in a given scope.
  -- They are not used in this plugin and are provided for (limited) backward compatibility.
end

return M
