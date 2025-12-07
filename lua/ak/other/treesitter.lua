-- The query editor can be opened by pressing o in the :InspectTree window,
-- with the :EditQuery command, or by calling vim.treesitter.query.edit() directly.
-- := vim.treesitter.highlighter.active

-- ron: rusty object notation, rasi: rofi, rst: python
-- stylua: ignore
local languages = { -- 45
  -- These are already pre-installed with Neovim. Used as an example.
  "lua",
  "vimdoc",
  "markdown",
  -- Add here more languages with which you want to use tree-sitter
  -- To see available languages:
  -- - Execute `:=require('nvim-treesitter').get_available()`
  -- - Visit 'SUPPORTED_LANGUAGES.md' file at
  --   https://github.com/nvim-treesitter/nvim-treesitter/blob/main
  "awk", "bash", "bibtex", "c", "css", "diff",
  "fennel", "git_config", "gitcommit", "git_rebase", "gitignore", "gitattributes",
  "go", "gomod", "gowork", "gosum", "html", "javascript",
  "jsdoc", "json", "json5", "luadoc",
  "luap", "make", "markdown_inline", "ninja", "printf",
  "python", "query", "rasi", "regex", "ron", "rst",
  "rust", "sql", "toml", "tsx", "typescript", "vim",
  "yaml", "xml",
}
-- stylua: ignore end

-- local on_filetype = function(ev)
-- if not pcall(vim.treesitter.start, ev.buf) then -- instead of checking parsers on each startup...
--   require("nvim-treesitter")
--     .install(languages, { summary = true })
--     :await(function() vim.notify("Installed missing treesitter parsers. Restart neovim!") end)
--   return
-- end
-- Indentations, considered experimental, provided by the plugin:
-- if ev.match ~= "latex" then vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()" end
-- Folds:
-- vim.o.foldmethod = "expr"
-- vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
-- Injections:
-- Injections are used for multi-language documents, see `:h treesitter-language-injections`. No setup is needed.
-- Locals:
-- These queries can be used to look up definitions and references to identifiers in a given scope.
-- They are not used in this plugin and are provided for (limited) backward compatibility.
-- end

local isnt_installed = function(lang) return #vim.api.nvim_get_runtime_file('parser/' .. lang .. '.*', false) == 0 end
local to_install = vim.tbl_filter(isnt_installed, languages)
if #to_install > 0 then require('nvim-treesitter').install(to_install) end

local filetypes = {}
for _, lang in ipairs(languages) do
  for _, ft in ipairs(vim.treesitter.language.get_filetypes(lang)) do
    table.insert(filetypes, ft)
  end
end
local ts_start = function(ev) vim.treesitter.start(ev.buf) end
_G.Config.new_autocmd('FileType', filetypes, ts_start, 'Start tree-sitter')
