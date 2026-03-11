-- The query editor can be opened by pressing o in the :InspectTree window,
-- with the :EditQuery command, or by calling vim.treesitter.query.edit() directly.
-- := vim.treesitter.highlighter.active

-- ron: rusty object notation, rasi: rofi, rst: python
local languages = { -- 46
  -- These are already pre-installed with Neovim. Used as an example.
  -- 'lua',
  -- 'vimdoc',
  -- 'markdown',
  --
  -- Add here more languages with which you want to use tree-sitter
  -- To see available languages:
  -- - Execute `:=require('nvim-treesitter').get_available()`
  -- - Visit 'SUPPORTED_LANGUAGES.md' file at
  --   https://github.com/nvim-treesitter/nvim-treesitter/blob/main
  'awk',
  'bash',
  'bibtex',
  'c',
  'cpp',
  'css',
  'diff',
  'fennel',
  'git_config',
  'gitcommit',
  'git_rebase',
  'gitignore',
  'gitattributes',
  'go',
  'gomod',
  'gowork',
  'gosum',
  'html',
  'javascript',
  'jsdoc',
  'json',
  'json5',
  'luadoc',
  'luap',
  'make',
  'markdown_inline',
  'ninja',
  'printf',
  'python',
  'query',
  'rasi',
  'regex',
  'ron',
  'rst',
  'rust',
  'sql',
  'toml',
  'tsx',
  'typescript',
  'vim',
  'yaml',
  'xml',
}

-- Installed
local isnt_installed = function(lang) return #vim.api.nvim_get_runtime_file('parser/' .. lang .. '.*', false) == 0 end
local to_install = vim.tbl_filter(isnt_installed, languages)
if #to_install > 0 then require('nvim-treesitter').install(to_install) end

-- Enabled
local filetypes = {}
for _, lang in ipairs(languages) do
  for _, ft in ipairs(vim.treesitter.language.get_filetypes(lang)) do
    table.insert(filetypes, ft)
  end
end
vim.list_extend(filetypes, { 'markdown', 'quarto' })

local ts_start = function(ev) vim.treesitter.start(ev.buf) end
Config.new_autocmd('FileType', filetypes, ts_start, 'Start tree-sitter')

-- Miscellaneous adjustments
vim.treesitter.language.register('markdown', 'quarto')
vim.filetype.add({
  extension = { qmd = 'quarto', Qmd = 'quarto' },
})
