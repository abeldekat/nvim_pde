-- Useful when:
-- Picker has limited items (ie buffers, ui_select: hotkeys activated)
-- Picker displays most valuable results on top(ie oldfiles, visits)
-- Example less useful: Pick.files, top results have no extra meaning
local Pick = require("mini.pick")
local H = {}

H.labels = vim.split("abcdefghijklmnopqrstuvwxyz", "")
H.ns_id = { -- Visual clues namespace
  labels = vim.api.nvim_create_namespace("MiniPickLabels"),
}
H.get_label_idx = function(label)
  -- stylua: ignore
  for idx, l in ipairs(H.labels) do if l == label then return idx end end
end

-- Copied
H.clear_namespace = function(buf_id, ns_id) pcall(vim.api.nvim_buf_clear_namespace, buf_id, ns_id, 0, -1) end
-- Copied
H.set_extmark = function(...) pcall(vim.api.nvim_buf_set_extmark, ...) end
-- Copied from :h MiniPick
H.make_centered_window = function()
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

H.make_override_match = function(match_orig, data)
  -- premisse: items and stritems are constant and related, having the same ordering and length.
  return function(stritems, inds, query, do_sync)
    -- Make label, forcing selection, even when other stritems start with same char
    local make_unique_label = function(idx)
      local char = H.labels[idx]
      local underscored = string.format("%s_%s", char, char)
      return string.format("%s %s %s %s ", underscored, underscored, underscored, char)
    end
    local match = function() return match_orig(stritems, inds, query, do_sync) end

    -- Restore previously modified stritem
    if data.idx_selected then
      local idx = data.idx_selected
      stritems[idx] = string.sub(stritems[idx], string.len(make_unique_label(idx)) + 1)
    end
    data.idx_selected = nil

    -- Can query hold a label
    if #query ~= 1 then return match() end

    -- Find label idx
    local char = query[1]
    local label_idx = H.get_label_idx(char)
    if not label_idx or label_idx > data.nr_labels_to_add then return match() end

    -- Apply label
    stritems[label_idx] = string.format("%s%s", make_unique_label(label_idx), stritems[label_idx])
    data.idx_selected = label_idx -- remember, restore stritem if needed on next query input
    return match()
  end
end

H.make_override_show = function(show, data)
  local enter_key = vim.api.nvim_replace_termcodes("<cr>", true, true, true)
  local esc_key = vim.api.nvim_replace_termcodes("<esc>", true, true, true)
  local first_item -- detect scrolling
  local autosubmit -- all available items must fit in window and have a label
  return function(buf_id, items, query, opts) -- items are items --displayed--
    if data.idx_selected and autosubmit then -- label matched, handle autoselect
      data.idx_selected = nil
      vim.api.nvim_feedkeys(enter_key, "n", false)
      vim.api.nvim_feedkeys(esc_key, "n", false)
      return
    end

    if not first_item then first_item = items[1] end
    if not autosubmit then
      data.nr_labels_to_add = math.min(#H.labels, #items)
      autosubmit = #(Pick.get_picker_items() or {}) == data.nr_labels_to_add
    end

    show(buf_id, items, query, opts)
    H.clear_namespace(buf_id, H.ns_id.labels)

    -- Decide if clues can be shown
    if not (#query == 0 and first_item == items[1]) then return end

    local hl = autosubmit and "MiniPickMatchRanges" or "Comment"
    for i, label in ipairs(H.labels) do
      if i > #items then break end
      local virt_text = { { string.format("[%s]", label), hl } }
      local extmark_opts = { hl_mode = "combine", priority = 200, virt_text = virt_text, virt_text_pos = "eol" }
      H.set_extmark(buf_id, H.ns_id.labels, i - 1, 0, extmark_opts)
    end
  end
end

H.make_override_start = function(start)
  return function(opts)
    Pick.start = start -- Picker started, restore original
    local data = { -- Maybe: A setting in opts to disable autosubmit per picker
      idx_selected = nil, -- set in match when label is processed
      nr_labels_to_add = nil, -- initialized in show
    }
    opts.source.match = H.make_override_match(opts.source.match or Pick.default_match, data)
    opts.source.show = H.make_override_show(opts.source.show or Pick.default_show, data)

    return start(opts)
  end
end

H.make_labeled_ui_select = function()
  return function(items, opts, on_choice)
    Pick.start = H.make_override_start(Pick.start)
    Pick.ui_select(items, opts, on_choice)
  end
end

-- https://github.com/echasnovski/mini.nvim/discussions/1096
-- Notion of a picker func: Any function calling Pick.start
--
-- Advantage of this approach:
-- 1. The picker function is responsible for both items and show
-- 2. Reusability(no need to copy code from Pick.builtin.*)
-- Drawback: Another level of abstraction, decorating Pick.start temporarily
H.make_labeled = function(picker_func)
  return function(local_opts, start_opts)
    Pick.start = H.make_override_start(Pick.start)
    picker_func(local_opts, start_opts)
  end
end

-- POC: Override pickers defined in ak/config/editor/mini_pick.lua

-- Most relevant usage of labels in a picker because hotkeys are likely to be activated
Pick.registry.labeled_buffers = function(local_opts, _)
  local show_icons = true -- default true in Pick.builtin.buffers
  local source = { show = not show_icons and Pick.default_show or nil }
  local window = true and H.make_centered_window() or nil -- consistency with grapple
  local opts = { source = source, window = window }

  local picker_func = H.make_labeled(Pick.builtin.buffers)
  picker_func(local_opts, opts)
end

Pick.registry.labeled_lsp = function(local_opts, opts)
  local picker_func = H.make_labeled(MiniExtra.pickers.lsp)
  picker_func(local_opts, opts)
end

Pick.registry.labeled_oldfiles = function(local_opts, opts)
  local picker_func = H.make_labeled(MiniExtra.pickers.oldfiles)
  picker_func(local_opts, opts)
end

Pick.registry.labeled_history = function(local_opts, opts)
  local picker_func = H.make_labeled(MiniExtra.pickers.history)
  picker_func(local_opts, opts)
end

Pick.registry.labeled_ui_select = function(items, opts, on_choice)
  local picker_ui_select = H.make_labeled_ui_select()
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
