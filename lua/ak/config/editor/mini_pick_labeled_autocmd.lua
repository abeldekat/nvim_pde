-- Edge cases that are hard to fix:
-- 1:
-- a. Pick buffers, labeled, lots of buffers starting with "lua", autosubmit is not active
-- b. Press label 'l'(also first letter of "lua")
-- c  Note that the labeled item is -not- placed as first item in the list
-- d. Press enter
-- e.  Note that the labeled item is opened correctly, instead of the first item displayed

local Pick = require("mini.pick")
local Extra = require("mini.extra")

-- EPL: "Extra Labeled Picker"" functionality. Could be added to "H" in "mini.extra"
-- Useful when: Picker has limited items (ie buffers, ui_select: hotkeys activated)
-- Useful when: Picker displays most valuable results on top(ie oldfiles, visits)
-- Less useful: Pick.files, top results have no extra meaning
local EPL = {}

-- Helper data ================================================================

EPL.invert = function(tbl_in)
  local tbl_out = {}
  -- stylua: ignore
  for idx, l in ipairs(tbl_in) do tbl_out[l] = idx end
  return tbl_out
end
EPL.labels = vim.split("abcdefghijklmnopqrstuvwxyz", "")
EPL.labels_inv = EPL.invert(EPL.labels)
EPL.ns_id = { labels = vim.api.nvim_create_namespace("MiniPickLabels") } -- clues

-- Copied from mini.pick:
EPL.clear_namespace = function(buf_id, ns_id) pcall(vim.api.nvim_buf_clear_namespace, buf_id, ns_id, 0, -1) end
EPL.set_extmark = function(...) pcall(vim.api.nvim_buf_set_extmark, ...) end

-- Copied from :h MiniPick
EPL.make_centered_window = function()
  return {
    config = function()
      local height = math.floor(0.618 * vim.o.lines)
      local width = math.floor(0.618 * vim.o.columns)
      return {
        anchor = "NW",
        height = height,
        width = width,
        row = math.floor(0.5 * (vim.o.lines - height)),
        col = math.floor(0.5 * (vim.o.columns - width)),
      }
    end,
  }
end

EPL.make_override_match = function(match, data)
  -- premisse: items and stritems are constant and related, having the same ordering and length.
  return function(stritems, inds, query, do_sync)
    -- Restore previously modified stritem
    if data.idx_selected then
      local idx = data.idx_selected
      stritems[idx] = string.sub(stritems[idx], 2)
    end
    data.idx_selected = nil

    -- Can query hold a label
    if #query ~= 1 then return match(stritems, inds, query, do_sync) end

    -- Find label idx
    local char = query[1]
    local label_idx = EPL.labels_inv[char]
    if not label_idx or label_idx > data.max_labels then return match(stritems, inds, query, do_sync) end

    -- Apply label: In most cases, the items is shown as first item in list
    stritems[label_idx] = string.format("%s%s", char, stritems[label_idx])
    data.idx_selected = label_idx -- remember to restore stritem if needed on next query input
    return match(stritems, inds, query, do_sync)
  end
end

EPL.make_override_show = function(show, data)
  local enter_key = vim.api.nvim_replace_termcodes("<cr>", true, true, true)
  local first_item -- detect scrolling
  local autosubmit -- all available items must fit in window and have a label
  return function(buf_id, items, query, opts) -- items are items --displayed--
    if data.idx_selected and autosubmit then -- label matched
      vim.api.nvim_feedkeys(enter_key, "n", false)
      vim.api.nvim_feedkeys("<Ignore>", "n", false)
      return
    end

    if not first_item then first_item = items[1] end
    if not autosubmit then
      data.max_labels = math.min(#EPL.labels, #items)
      autosubmit = #(Pick.get_picker_items() or {}) == data.max_labels
    end

    show(buf_id, items, query, opts)
    EPL.clear_namespace(buf_id, EPL.ns_id.labels)
    if not (#query == 0 and first_item == items[1]) then return end

    local hl = autosubmit and "MiniPickMatchRanges" or "Comment"
    for i, label in ipairs(EPL.labels) do
      if i > data.max_labels then break end
      local virt_text = { { string.format("[%s]", label), hl } }
      local extmark_opts = { hl_mode = "combine", priority = 200, virt_text = virt_text, virt_text_pos = "eol" }
      EPL.set_extmark(buf_id, EPL.ns_id.labels, i - 1, 0, extmark_opts)
    end
  end
end

EPL.make_override_choose = function(choose, data)
  -- must override, in edge cases the item is not shown first in the list
  return function(item)
    if data.idx_selected then item = Pick.get_picker_items()[data.idx_selected] end
    return choose(item)
  end
end

-- Public  ================================================================

-- NOTE:  only works if H.advance in pick(line 2075) does not schedule the MiniPickStart event!
-- Take opts = { label = true } is into account,
-- and override functions opts.source.{match, show, choose}
Extra.pickers_enable_label_in_options = function()
  local group = vim.api.nvim_create_augroup("minipick-hooks", { clear = true })
  vim.api.nvim_create_autocmd("User", {
    pattern = "MiniPickStart",
    group = group,
    desc = "Augment pickers with labels",
    callback = function()
      local opts = Pick.get_picker_opts()
      if not opts then return end

      local should_label = opts.label
      if not should_label and vim.ui.select == Extra.pickers.labeled_ui_select then should_label = true end
      if not should_label then return end

      local data = {
        idx_selected = nil, -- set in match when label is detected
        max_labels = nil, -- set in show
      }
      opts.source.match = EPL.make_override_match(opts.source.match, data)
      opts.source.show = EPL.make_override_show(opts.source.show, data)
      opts.source.choose = EPL.make_override_choose(opts.source.choose, data)
      Pick.set_picker_opts(opts)
    end,
  })
end

-- Use vim.ui.select = Extra.pickers.labeled_ui_select -- Pick.ui_select
Extra.pickers.labeled_ui_select = function(items, opts, on_choice) Pick.ui_select(items, opts, on_choice) end

-- POC ================================================================

Extra.pickers_enable_label_in_options() -- take opts = { label = true } into account
local map = vim.keymap.set

local labeled_buffers = function()
  local show_icons = true
  local source = { show = not show_icons and Pick.default_show or nil }
  local window = true and EPL.make_centered_window() or nil
  local opts = { label = true, source = source, window = window }

  Pick.builtin.buffers({}, opts)
end
map("n", "<leader>;", labeled_buffers, { desc = "Labeled buffers pick", silent = true })

local labeled_lsp = function() Extra.pickers.lsp({ scope = "document_symbol" }, { label = true }) end
map("n", "<leader>b", labeled_lsp, { desc = "Labeled buffer symbols", silent = true })

local labeled_oldfiles = function() Extra.pickers.oldfiles({ current_dir = true }, { label = true }) end
map("n", "<leader>r", labeled_oldfiles, { desc = "Labeled recent (rel)", silent = true })

local labeled_his = function() Extra.pickers.history({ scope = ":" }, { label = true }) end
map("n", "<leader>f:", labeled_his, { desc = "Labeled ':' history" })

local on_choice = function(choice)
  if not choice then return end
  vim.notify(choice)
end
local labeled_ui_select = function()
  local org = vim.ui.select
  -- vim.ui.select = Extra.pickers.labeled_ui_select -- Pick.ui_select
  vim.ui.select({ "Hello", "Helloooo", "Helloooooo" }, { prompt = "Say hi" }, on_choice)
  vim.ui.select = org
end
map("n", "<leader>fU", labeled_ui_select, { desc = "Labeled ui select", silent = true })
