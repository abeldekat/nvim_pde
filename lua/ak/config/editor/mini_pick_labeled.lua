local Pick = require("mini.pick")
local H = {} -- Helper functions for custom pickers

-- when applicable, labels to use for "hotkeys"
H.labels = "abcdefghijklmnopqrstuvwxyz"
-- TODO: too many items: no labels, performance
H.labels_treshold = 1000

H.make_centered_window = function() -- copied from :h MiniPick
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

-- Returns 0 based cols start and end.
-- Corrects when icons are included to the buffer(extmarks)
H.find_label = function(item, which_part, icon_length)
  local label_len = 3
  local find_from = which_part == 2 and (#item.text - label_len) or which_part

  local startpos, _ = string.find(item.text, "[", find_from, true)
  startpos = startpos and (startpos - 1) + icon_length or startpos
  local endpos = startpos and startpos + label_len or startpos
  return startpos, endpos
end

H.add_labels = function(items)
  for idx, item in ipairs(items) do
    local label = string.sub(H.labels, idx, idx)
    label = label == "" and "[ ]" or ("[" .. label .. "]")
    -- the first label does the trick!
    item.text = string.format("%s %s %s", label, item.text, label)
  end
  return items
end

H.make_show_with_labels = function(show_orig, show_icons)
  return function(buf_id, items, query, opts)
    local icon_length = show_icons and 5 or 0 -- icon and space
    local use_hotkey = #Pick.get_picker_items() <= string.len(H.labels)
    local hl = use_hotkey and "MiniPickMatchRanges" or "Comment"

    local hl_label = function(find_from, item, idx)
      local startpos, endpos = H.find_label(item, find_from, icon_length)
      if startpos and endpos then vim.api.nvim_buf_add_highlight(buf_id, 0, hl, idx - 1, startpos, endpos) end
    end
    show_orig(buf_id, items, query, opts)

    for idx, item in ipairs(items) do
      hl_label(1, item, idx) -- start of label surrounding
      hl_label(2, item, idx) -- end of label surrounding
    end
    if use_hotkey and query and #query == 1 then
      local submit = vim.api.nvim_replace_termcodes("<cr>", true, false, true)
      vim.api.nvim_feedkeys(submit, "n", false) -- hotkey
      vim.api.nvim_feedkeys("<Ignore>", "n", false) -- prevent extra cr cursor movement
    end
  end
end

-- https://github.com/echasnovski/mini.nvim/discussions/1096
-- Advantage of this approach:
-- 1. The picker function is responsible for both items and show
-- 2. Reusability(no need to copy code from Pick.builtin.*)
-- Drawback: Another level of abstraction, decorating Pick.start temporarily
--
-- From the help, regarding icons:
--
-- Disable icons in |MiniPick.builtin| pickers related to paths:
-- local pick = require('mini.pick')
-- pick.setup({ source = { show = pick.default_show } })
--
-- The problem:
-- This function decorates the show function and has no no access
-- to the opts defined in mini.pick, H.show_with_icons
--
-- Current solution:
-- When calling this function, provide show_icons as an argument
--
-- Currently, this approach works when:
-- each item is a table containing a text field
--
-- Not working:
-- For example: files(or anything from the cli), oldfiles. Items is a list of strings
--
-- Confirmed to work:
-- help (not useful)
-- extra.lsp (somewhat useful)
H.make_labeled = function(picker_func, show_icons)
  return function(local_opts, start_opts)
    local start_orig = Pick.start
    local set_picker_items_orig = Pick.set_picker_items

    ---@diagnostic disable-next-line: duplicate-set-field
    Pick.set_picker_items = function(items, opts)
      Pick.set_picker_items = set_picker_items_orig -- immediately restore
      items = H.add_labels(items)
      set_picker_items_orig(items, opts)
    end

    ---@diagnostic disable-next-line: duplicate-set-field
    Pick.start = function(opts) -- when entering start, there is always a show...
      Pick.start = start_orig -- immediately restore
      local show_orig = opts.source.show
      opts.source.show = H.make_show_with_labels(show_orig, show_icons)
      return start_orig(opts)
    end
    picker_func(local_opts, start_opts)
  end
end

-- The most relevant usage of labels in a picker...
Pick.registry.labeled_buffers = function(local_opts, _)
  local show_icons = true -- default true in Pick.builtin.buffers
  local source = { show = not show_icons and Pick.default_show or nil }
  local window = true and H.make_centered_window() or nil -- consistency with grapple
  local opts = { source = source, window = window }

  local picker_func = H.make_labeled(Pick.builtin.buffers, show_icons)
  picker_func(local_opts, opts)
end

Pick.registry.labeled_lsp = function(local_opts, opts) -- POC
  local show_icons = false -- icons are already present in source.items
  local picker_func = H.make_labeled(MiniExtra.pickers.lsp, show_icons)
  picker_func(local_opts, opts)
end

local map = vim.keymap.set
map("n", "<leader>'", Pick.registry.labeled_buffers, { desc = "Labeled buffers pick", silent = true })
map("n", "<leader>b", function()
  local local_opts = { scope = "document_symbol" }
  local opts = {}
  Pick.registry.labeled_lsp(local_opts, opts)
end, { desc = "Labeled buffer symbols", silent = true })
-- Pick.setup({})
