local Util = require("ak.util")
-- MiniIcons.tweak_lsp_kind()
MiniIcons.tweak_lsp_kind("replace") -- Only icon instead of icon and text

local process_items = function(items, base)
  local opts = { filtersort = CompletionBlinked.fuzzy }
  return MiniCompletion.default_process_items(items, base, opts)
end

local opts = {
  mappings = { -- Tmux conflict <C-Space>:
    force_twostep = "<C-A-Space>", --  "<C-Space>",
    -- Force fallback is very usefull when completing a function *reference*
    -- using lsp snippets. No need to remove the arguments...
    force_fallback = "<A-Space>", -- Force fallback completion
  },
  -- Use the default completefunc instead of omnifunc to have
  -- ctrl-o to temporarily escape to normal mode. See mini discussions #1736
  lsp_completion = { auto_setup = false }, -- source_func = "omnifunc"
  window = { info = { border = "single" } },
}
if Util.mini_completion_fuzzy_provider == "blink" then
  require("ak.mini.completion_blinked").setup()
  opts.lsp_completion.process_items = process_items
end
require("mini.completion").setup(opts)

local keycode = vim.keycode or function(x) return vim.api.nvim_replace_termcodes(x, true, true, true) end
local keys = {
  ["ctrl-k"] = keycode("<C-k>"), -- enter digraph, the default
  ["ctrl-y"] = keycode("<C-y>"), -- confirm selected item
  ["ctrl-n_ctrl-y"] = keycode("<C-n><C-y>"), -- confirm first item: TODO: Does not autoimport!
}

---@diagnostic disable-next-line: duplicate-set-field
_G.confirm_action = function() -- works best with noinsert...
  if vim.fn.pumvisible() ~= 0 then
    local item_selected = vim.fn.complete_info()["selected"] ~= -1
    return item_selected and keys["ctrl-y"] or keys["ctrl-n_ctrl-y"]
  else
    return keys["ctrl-k"] -- enter digraph
  end
end

-- Prefer typing c-k over c-y to accept completion
vim.keymap.set("i", "<C-k>", "v:lua._G.confirm_action()", { expr = true })
