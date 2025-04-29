local Util = require("ak.util")
local use_completeopt_noinsert = false

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
local pumvisible = vim.fn.pumvisible -- backup
local H = {} -- needed to restore keymap inside H.noselect_confirm
H.noselect_confirm = function()
  if vim.fn.pumvisible() == 0 then -- digraph
    vim.keymap.del("i", "<C-k>")
    vim.api.nvim_feedkeys(keys["ctrl-k"], "i", true)
    vim.schedule(function() vim.keymap.set("i", "<C-k>", H.noselect_confirm, {}) end)
    return
  end

  local item_selected = vim.fn.complete_info()["selected"] ~= -1 -- user selection
  if item_selected then
    vim.api.nvim_feedkeys(keys["ctrl-y"], "i", false)
    return
  end

  -- User did not select an item; select the first and confirm
  local pmenusel = vim.api.nvim_get_hl(0, { name = "PmenuSel", link = false }) -- backup the hl
  vim.api.nvim_set_hl(0, "PmenuSel", { link = "Pmenu" }) -- HACK: prevent flashing on automatic select...

  ---@diagnostic disable-next-line: duplicate-set-field
  vim.fn.pumvisible = function() return 0 end -- HACK: H.show_info_window: prevent a flashing info window
  vim.api.nvim_feedkeys(keys["ctrl-n"], "i", false)

  local confirm_and_restore = vim.schedule_wrap(function()
    vim.api.nvim_feedkeys(keys["ctrl-y"], "i", false) -- confirm
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

-- See discussion #1767: Autoimport on a keymap using ctrl-n and ctrl-y with noselect
if use_completeopt_noinsert then
  vim.keymap.set("i", "<C-k>", "v:lua._G.noinsert_confirm()", { expr = true })
else
  vim.keymap.set("i", "<C-k>", H.noselect_confirm, {})
end

local opts = {
  delay = { info = info_delay },
  mappings = { -- Tmux conflict <C-Space>:
    force_twostep = "<C-A-Space>", --  "<C-Space>",
    -- Force fallback is very usefull when completing a function *reference*
    -- using lsp snippets. No need to remove the arguments...
    force_fallback = "<A-Space>", -- Force fallback completion
  },
  -- Use completefunc instead of omnifunc to have ctrl-o available
  -- See mini discussions #1736
  lsp_completion = { auto_setup = false }, -- source_func = "omnifunc"
  window = { info = { border = "single" } },
}
if Util.mini_completion_fuzzy_provider == "blink" then
  require("ak.mini.completion_blinked").setup()
  opts.lsp_completion.process_items = function(items, base)
    local opts = { filtersort = CompletionBlinked.fuzzy }
    return MiniCompletion.default_process_items(items, base, opts)
  end
end
require("mini.completion").setup(opts)

-- See issue #1768: Show icons first in completion items
-- MiniIcons.tweak_lsp_kind("replace") -- Only icon instead of icon and text
local completefunc_lsp = MiniCompletion.completefunc_lsp
---@diagnostic disable-next-line: duplicate-set-field
MiniCompletion.completefunc_lsp = function(findstart, base)
  local res = completefunc_lsp(findstart, base)
  if res and type(res) == "table" and #res > 0 and res[1].abbr then
    for _, item in ipairs(res) do
      item.abbr = MiniIcons.get("lsp", item.kind) .. " " .. item.abbr
    end
  end
  return res
end
