-- In insertmode, words in buffer, ctrl-n. See :h ins-completion

-- Questions:
-- Is it possible to preselect the first item?
-- Are there situations that completion should be disabled
-- How to use dadbod completion? Omnifunc? Trouble typing ctrl-x

MiniIcons.tweak_lsp_kind() -- performance, call lazily

-- local lsp_get_filterword = function(x) return x.filterText or x.label end

-- local filtersort = function(items, base)
--   if base == "" then return vim.deepcopy(items) end
--   return vim.fn.matchfuzzy(items, base, { text_cb = lsp_get_filterword })
-- end

--- @param items table Array of items from LSP response.
--- @param base string Base for which completion is done. See |complete-functions|.
local process_items = function(items, base)
  -- filter_sort can also be: prefix, fuzzy, none, or a function
  -- local opts = { filtersort = "fuzzy" } -- fuzzy is the default if in completeopt
  local opts = {}
  return MiniCompletion.default_process_items(items, base, opts)
end

require("mini.completion").setup({
  mappings = { -- Tmux conflict <C-Space>:
    force_twostep = "<C-A-Space>", --  "<C-Space>",
    -- Force fallback is very usefull when completing a function *reference*
    -- using lsp snippets. No need to remove the arguments...
    force_fallback = "<A-Space>", -- Force fallback completion
  },
  lsp_completion = {
    auto_setup = false,
    source_func = "omnifunc",
    process_items = process_items,
  },
  window = {
    info = { border = "double" },
    signature = { border = "double" },
  },
})

vim.opt.completeopt:append("fuzzy") -- Use fuzzy matching for built-in completion
