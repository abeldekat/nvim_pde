-- In insertmode, words in buffer, ctrl-n
-- Also ctrl-x ctrl-n. See :h ins-completion
-- ctrl-x ctrl-u: user defined completion

-- Questions:
-- Is it possible to preselect the first item?
-- Are there situations that completion should be disabled
-- Source_func: When to change this setting
-- How to use dadbod completion? Omnifunc? Trouble typing ctrl-x

MiniIcons.tweak_lsp_kind() -- call lazily

require("mini.completion").setup({
  mappings = { -- Tmux conflict <C-Space>:
    force_fallback = "<C-A-Space>", -- "<A-Space>", -- Force fallback completion
    force_twostep = "<A-Space>", --  "<C-Space>", -- Force two-step completion
  },

  lsp_completion = { -- see also nvim echasnovski
    auto_setup = false,
    source_func = "omnifunc",
    -- process_items = function(items, base)
    --   -- Don't show 'Text' and 'Snippet' suggestions
    --   items = vim.tbl_filter(function(x) return x.kind ~= 1 and x.kind ~= 15 end, items)
    --   return MiniCompletion.default_process_items(items, base)
    -- end,
  },

  window = {
    info = { border = "double" },
    signature = { border = "double" },
  },
})

if vim.fn.has("nvim-0.11") == 1 then
  vim.opt.completeopt:append("fuzzy") -- Use fuzzy matching for built-in completion
end
