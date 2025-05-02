local Util = require("ak.util")
local use_completeopt_noinsert = false
local no_expandable_indicator = true

if use_completeopt_noinsert then
  vim.o.completeopt = "menuone,noinsert,fuzzy" -- first completion item is preselected
end

local keycode = vim.keycode or function(x) return vim.api.nvim_replace_termcodes(x, true, true, true) end
local keys = {
  ["ctrl-k"] = keycode("<C-k>"), -- enter digraph, default ctrl-k
  ["ctrl-n"] = keycode("<C-n>"), -- select item
  ["ctrl-y"] = keycode("<C-y>"), -- confirm selected item
}

local info_delay = 50
local autoselect_delay = info_delay + 50
local autoselect_timer = vim.loop.new_timer()
local pumvisible = vim.fn.pumvisible -- backup the function
local H = {} -- needed to restore keymap from inside function H.noselect_confirm
H.noselect_confirm = function()
  if vim.fn.pumvisible() == 0 then -- digraph
    vim.keymap.del("i", "<C-k>")
    vim.api.nvim_feedkeys(keys["ctrl-k"], "i", true)
    vim.schedule(function() vim.keymap.set("i", "<C-k>", H.noselect_confirm, {}) end)
    return
  end

  if vim.fn.complete_info()["selected"] ~= -1 then -- user selection
    vim.api.nvim_feedkeys(keys["ctrl-y"], "i", false)
    return
  end

  -- User did not select an item; select the first and confirm
  local pmenusel = vim.api.nvim_get_hl(0, { name = "PmenuSel", link = false }) -- backup the current hl
  vim.api.nvim_set_hl(0, "PmenuSel", { link = "Pmenu" }) -- HACK: prevent flashing on automatic select...

  ---@diagnostic disable-next-line: duplicate-set-field
  vim.fn.pumvisible = function() return 0 end -- HACK: H.show_info_window: prevent a flashing info window
  vim.api.nvim_feedkeys(keys["ctrl-n"], "i", false) -- select first item

  local confirm_and_restore = vim.schedule_wrap(function()
    vim.api.nvim_feedkeys(keys["ctrl-y"], "i", false) -- confirm first item
    vim.fn.pumvisible = pumvisible -- restore
    ---@diagnostic disable-next-line: param-type-mismatch
    vim.api.nvim_set_hl(0, "PmenuSel", pmenusel) -- restore
  end)
  ---@diagnostic disable-next-line: need-check-nil
  autoselect_timer:start(autoselect_delay, 0, confirm_and_restore)
end

_G.noinsert_confirm = function()
  local key = vim.fn.pumvisible ~= 0 and "ctrl-y" or "ctrl-k"
  return keys[key]
end

if use_completeopt_noinsert then -- see discussion #1767
  vim.keymap.set("i", "<C-k>", "v:lua._G.noinsert_confirm()", { expr = true })
else
  vim.keymap.set("i", "<C-k>", H.noselect_confirm, {})
end

local make_process_opts = function() -- see discussion #1771
  if Util.mini_completion_fuzzy_provider == "blink" then
    require("ak.mini.completion_blinked").setup()
    return { filtersort = CompletionBlinked.fuzzy }
  end

  if vim.fn.has("nvim-0.12") == 1 then
    local lsp_get_filterword = function(x) return x.filterText or x.label end
    local filtersort = function(items, base)
      if base == "" then return vim.deepcopy(items) end
      return vim.fn.matchfuzzy(items, base, { text_cb = lsp_get_filterword, camelcase = false })
    end
    return { filtersort = filtersort }
  end

  return nil
end
local process_opts = make_process_opts()
local process_items = function(items, base) return MiniCompletion.default_process_items(items, base, process_opts) end

require("mini.completion").setup({
  delay = { info = info_delay },
  lsp_completion = { -- use completefunc instead of omnifunc to have ctrl-o available, see discussion #1736
    auto_setup = false,
    process_items = process_items,
    -- source_func = "omnifunc"
  },
  mappings = { -- <C-Space> is for tmux:
    force_twostep = "<C-A-Space>", --  "<C-Space>",
    force_fallback = "<A-Space>", -- Force fallback completion
  },
  window = { info = { border = "single" } },
})

-- See issue #1768: Show icons first in completion items
-- MiniIcons.tweak_lsp_kind("replace") -- Only icon instead of icon and text
local completefunc_lsp = MiniCompletion.completefunc_lsp
---@diagnostic disable-next-line: duplicate-set-field
MiniCompletion.completefunc_lsp = function(findstart, base)
  local res = completefunc_lsp(findstart, base)
  if not (res and type(res) == "table" and #res > 0 and res[1].abbr) then return res end

  for _, item in ipairs(res) do
    item.abbr = MiniIcons.get("lsp", item.kind) .. " " .. item.abbr
    item.kind = "" -- not needed when using the icon...
    if no_expandable_indicator and item.user_data.lsp.needs_snippet_insert then item.menu = string.sub(item.menu, 3) end
  end
  return res
end
