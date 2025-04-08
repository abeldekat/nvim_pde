MiniIcons.tweak_lsp_kind() -- performance, call lazily

-- local lsp_get_filterword = function(x) return x.filterText or x.label end

-- local filtersort = function(items, base)
--   if base == "" then return vim.deepcopy(items) end
--   return vim.fn.matchfuzzy(items, base, { text_cb = lsp_get_filterword })
-- end

-- --- @param items table Array of items from LSP response.
-- --- @param base string Base for which completion is done. See |complete-functions|.
-- local process_items = function(items, base)
--   -- filter_sort can also be: prefix, fuzzy, none, or a function
--   -- local opts = { filtersort = "fuzzy" } -- fuzzy is the default if in completeopt
--   local opts = {}
--   return MiniCompletion.default_process_items(items, base, opts)
-- end

require("mini.completion").setup({
  mappings = { -- Tmux conflict <C-Space>:
    force_twostep = "<C-A-Space>", --  "<C-Space>",
    -- Force fallback is very usefull when completing a function *reference*
    -- using lsp snippets. No need to remove the arguments...
    force_fallback = "<A-Space>", -- Force fallback completion
  },
  -- Using the default completefunc to be able to use ctrl-o to temporarily
  -- escape to normal mode. See mini discussions #1736
  lsp_completion = { auto_setup = false },
  -- lsp_completion = { auto_setup = false, source_func = "omnifunc" },
})
