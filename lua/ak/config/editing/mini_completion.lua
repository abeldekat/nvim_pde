---@diagnostic disable: duplicate-set-field

local Util = require("ak.util")

-- See discussion #1771: Fuzzy matching with blink.cmp algorithm
local make_process_items = function() -- see discussion #1771
  if Util.mini_completion_fuzzy_provider ~= "blink" then return end

  require("akmini.completion_blinked").setup()
  local process_opts = { filtersort = CompletionBlinked.fuzzy }
  return function(items, base) return MiniCompletion.default_process_items(items, base, process_opts) end
end

-- Setup
require("mini.completion").setup({
  delay = { info = 50 },
  lsp_completion = { -- use completefunc instead of omnifunc to have ctrl-o available, see discussion #1736
    auto_setup = false,
    process_items = make_process_items(),
    -- source_func = "omnifunc"
  },
  mappings = { -- <C-Space> is for tmux:
    force_twostep = "<C-A-Space>", --  "<C-Space>",
    force_fallback = "<A-Space>", -- Force fallback completion
  },
  window = { info = { border = "single" } },
})

-- See discussion #1767: Autoimport on a keymap using ctrl-n and ctrl-y with noselect
local function make_steps_smart_confirm()
  local autoselect_delay = MiniCompletion.config.delay.info * 2
  local autoselect_timer = vim.loop.new_timer() or {}
  local key_ctrl_y = vim.keycode("<C-y>")
  local pumvisible_org = vim.fn.pumvisible -- backup the core function

  local condition_selectconfirm = function()
    return vim.fn.pumvisible() ~= 0 and vim.fn.complete_info()["selected"] == -1
  end
  local action_selectconfirm = function()
    vim.fn.pumvisible = function() return 0 end -- HACK: H.show_info_window: prevent flashing info window
    local hl_org = vim.api.nvim_get_hl(0, { name = "PmenuSel", link = false }) --[[@as vim.api.keyset.highlight]]
    vim.api.nvim_set_hl(0, "PmenuSel", { link = "Pmenu" }) -- HACK: prevent flashing on automatic select...
    local confirm_and_restore = vim.schedule_wrap(function()
      vim.api.nvim_feedkeys(key_ctrl_y, "i", false) -- confirm auto-selected first item
      vim.fn.pumvisible = pumvisible_org -- restore function
      vim.api.nvim_set_hl(0, "PmenuSel", hl_org) -- restore highlight
    end)
    autoselect_timer:start(autoselect_delay, 0, confirm_and_restore)
    return "<C-n>" -- select first item, no hl, no info window
  end

  local condition_confirm = function() return vim.fn.pumvisible() ~= 0 and vim.fn.complete_info()["selected"] ~= -1 end
  local action_confirm = function() return "<C-y>" end

  local steps_selectconfirm = { condition = condition_selectconfirm, action = action_selectconfirm }
  local steps_confirm = { condition = condition_confirm, action = action_confirm }
  return { steps_selectconfirm, steps_confirm }
end
require("mini.keymap").map_multistep("i", "<C-k>", make_steps_smart_confirm())

-- Last step, see issue 1768: Show icons first in completion items
local tweak_menu = true
if not tweak_menu then
  MiniIcons.tweak_lsp_kind()
  return
end

MiniIcons.tweak_lsp_kind("replace") -- only show icon instead of icon and text
local tweak = function(item) -- :h complete-items
  if item.user_data.lsp.needs_snippet_insert then item.menu = string.sub(item.menu, 3) end -- remove "S "
end
local completefunc_lsp_org = MiniCompletion.completefunc_lsp

MiniCompletion.completefunc_lsp = function(findstart, base)
  local res = completefunc_lsp_org(findstart, base)
  if not (res and type(res) == "table" and #res > 0 and res[1].abbr) then return res end

  vim.iter(res):each(tweak)
  return res
end
