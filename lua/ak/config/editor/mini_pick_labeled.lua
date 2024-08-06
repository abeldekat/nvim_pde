local Pick = require("mini.pick")

-- L: Labeled pickers. Useful when:
-- Picker has limited items (ie buffers, ui_select: hotkeys activated)
-- Picker displays most valuable results on top(ie oldfiles, visits)
-- Less useful: Pick.files, top results have no extra meaning
local L = {}

L.invert = function(tbl_in)
  local tbl_out = {}
  -- stylua: ignore
  for idx, l in ipairs(tbl_in) do tbl_out[l] = idx end
  return tbl_out
end
L.labels = vim.split("abcdefghijklmnopqrstuvwxyz", "")
L.labels_inv = L.invert(L.labels)
L.ns_id = { labels = vim.api.nvim_create_namespace("MiniPickLabels") } -- clues

-- Copied from mini.pick:
L.clear_namespace = function(buf_id, ns_id) pcall(vim.api.nvim_buf_clear_namespace, buf_id, ns_id, 0, -1) end
L.set_extmark = function(...) pcall(vim.api.nvim_buf_set_extmark, ...) end
L.make_centered_window = function() -- Copied from :h MiniPick
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

L.make_override_match = function(match, data)
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
    local label_idx = L.labels_inv[char]
    if not label_idx or label_idx > data.max_labels then return match(stritems, inds, query, do_sync) end

    -- Apply label: In most cases, the items is shown as first item in list
    stritems[label_idx] = string.format("%s%s", char, stritems[label_idx])
    data.idx_selected = label_idx -- remember to restore stritem if needed on next query input
    return match(stritems, inds, query, do_sync)
  end
end

L.make_override_show = function(show, data)
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
      data.max_labels = math.min(#L.labels, #items)
      autosubmit = #(Pick.get_picker_items() or {}) == data.max_labels
    end

    show(buf_id, items, query, opts)
    L.clear_namespace(buf_id, L.ns_id.labels)
    if not (#query == 0 and first_item == items[1]) then return end

    local hl = autosubmit and "MiniPickMatchRanges" or "Comment"
    for i, label in ipairs(L.labels) do
      if i > data.max_labels then break end
      local virt_text = { { string.format("[%s]", label), hl } }
      local extmark_opts = { hl_mode = "combine", priority = 200, virt_text = virt_text, virt_text_pos = "eol" }
      L.set_extmark(buf_id, L.ns_id.labels, i - 1, 0, extmark_opts)
    end
  end
end

L.make_override_choose = function(choose, data)
  -- must override, in edge cases the items is not shown as first item in list
  return function(item)
    if data.idx_selected then item = Pick.get_picker_items()[data.idx_selected] end
    return choose(item)
  end
end

-- Override public function Pick.start temporarily
-- Only needed to reuse code in Pick.builtin and Extra.pickers
L.make_override_start = function(start)
  return function(opts)
    Pick.start = start -- Picker started, restore original
    local data = {
      idx_selected = nil, -- set in match when label is detected
      max_labels = nil, -- set in show
    }
    opts.source.match = L.make_override_match(opts.source.match or Pick.default_match, data)
    opts.source.show = L.make_override_show(opts.source.show or Pick.default_show, data)
    opts.source.choose = L.make_override_choose(opts.source.choose or Pick.default_choose, data)

    return start(opts)
  end
end

-- https://github.com/echasnovski/mini.nvim/discussions/1109
L.make_labeled_ui_select = function()
  return function(items, opts, on_choice)
    Pick.start = L.make_override_start(Pick.start)
    Pick.ui_select(items, opts, on_choice)
  end
end

-- https://github.com/echasnovski/mini.nvim/discussions/1109
L.make_labeled = function(picker_func)
  return function(local_opts, start_opts)
    Pick.start = L.make_override_start(Pick.start)
    picker_func(local_opts, start_opts)
  end
end

Pick.registry.labeled_buffers = function(local_opts, _)
  local show_icons = true
  local source = { show = not show_icons and Pick.default_show or nil }
  local window = true and L.make_centered_window() or nil
  local opts = { source = source, window = window }

  local picker_func = L.make_labeled(Pick.builtin.buffers)
  picker_func(local_opts, opts)
end

Pick.registry.labeled_lsp = function(local_opts, opts)
  local picker_func = L.make_labeled(MiniExtra.pickers.lsp)
  picker_func(local_opts, opts)
end

Pick.registry.labeled_oldfiles = function(local_opts, opts)
  local picker_func = L.make_labeled(MiniExtra.pickers.oldfiles)
  picker_func(local_opts, opts)
end

Pick.registry.labeled_history = function(local_opts, opts)
  local picker_func = L.make_labeled(MiniExtra.pickers.history)
  picker_func(local_opts, opts)
end

-- Use vim.ui.select = Pick.registry.labeled_ui_select -- Pick.ui_select
Pick.registry.labeled_ui_select = function(items, opts, on_choice)
  local picker_ui_select = L.make_labeled_ui_select()
  picker_ui_select(items, opts, on_choice)
end

local map = vim.keymap.set

local buffers = Pick.registry.labeled_buffers
map("n", "<leader>;", buffers, { desc = "Labeled buffers pick", silent = true })

local lsp = function() Pick.registry.labeled_lsp({ scope = "document_symbol" }, {}) end
map("n", "<leader>b", lsp, { desc = "Labeled buffer symbols", silent = true })

local oldfiles = function() Pick.registry.labeled_oldfiles({ current_dir = true }, {}) end
map("n", "<leader>r", oldfiles, { desc = "Labeled recent (rel)", silent = true })

local his = function() Pick.registry.labeled_history({ scope = ":" }) end
map("n", "<leader>f:", his, { desc = "Labeled ':' history" })

local hellos = { "hello", "Helloo", "Hellooo", "Helloooo", "Hellooooo", "Helloooooo" }
local on_choice = function(choice)
  if not choice then return end
  vim.notify(choice)
end
local ui_select = function()
  local org = vim.ui.select
  vim.ui.select = Pick.registry.labeled_ui_select -- Pick.ui_select
  vim.ui.select(hellos, { prompt = "Say hi" }, on_choice)
  vim.ui.select = org
end
map("n", "<leader>fU", ui_select, { desc = "Labeled ui select", silent = true })
