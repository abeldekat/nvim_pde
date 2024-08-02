local Pick = require("mini.pick")
local H = {}

-- Labels to use
H.labels = "abcdefghijklmnopqrstuvwxyz"
-- Visual clues namespace
H.ns_id = {
  labels = vim.api.nvim_create_namespace("MiniPickLabels"),
}
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
-- Returns label at index
H.label_at_index = function(idx) return H.labels:sub(idx, idx) end

-- NOTE: When source.items is a schedule-wrapped function, calling set_picker_items directly,
-- overriding source.items is not possible. Example: MiniExtra.oldfiles
--
-- NOTE: When the items are strings, it's not possible to add a label field to the item
-- Example: MiniExtra.oldfiles. Oldfiles is not working when items(list of strings)
-- are transformed to items(list of { label = "<somelabel", text = "contents of item"}).
H.make_override_set_items = function(picker_set_items_orig, runtime_vars)
  local nr_of_labels = #H.labels
  return function(items, opts)
    Pick.set_picker_items = picker_set_items_orig -- items are known, restore original
    local nr_of_items = #items
    runtime_vars.items = items -- used to test for equality to find the label for a displayed item
    for i = 1, nr_of_labels do -- store label-item combination for the first x items
      if nr_of_items < i then break end
      local label = H.label_at_index(i)
      runtime_vars.labels_to_items[label] = items[i]
    end
    if nr_of_items <= nr_of_labels then runtime_vars.use_hotkey = true end

    picker_set_items_orig(items, opts)
  end
end

-- 1. stritems and inds are always the same on each match invocation
-- 2. items and stritems are related, having the same ordering and length.
H.make_override_match = function(match_orig)
  local labels_have_been_added = false
  local nr_of_labels = #H.labels
  return function(stritems, inds, query, do_sync)
    -- Add labels
    local nr_of_stritems = #stritems
    if not labels_have_been_added then
      for i = 1, nr_of_labels do
        if nr_of_stritems < i then break end
        -- Append label as first char, forcing selection:
        stritems[i] = string.format("%s %s", H.label_at_index(i), stritems[i])
      end
    end
    labels_have_been_added = true
    -- Invoke original match function
    return match_orig(stritems, inds, query, do_sync)
  end
end

-- Add clues to the items displayed.
H.make_override_show = function(show_orig, runtime_vars)
  local nr_of_labels = #H.labels
  return function(buf_id, items, query, opts)
    show_orig(buf_id, items, query, opts) -- invoke original show function

    local add_clues = function(idx, item_displayed, hl)
      local find_label = function()
        for label, item in pairs(runtime_vars.labels_to_items) do
          if item == item_displayed then return label end
        end
      end
      local label = find_label()
      if not label then return end

      local virt_text = { { string.format("[%s]", label), hl } }
      local extmark_opts = { hl_mode = "combine", priority = 200, virt_text = virt_text, virt_text_pos = "eol" }
      H.set_extmark(buf_id, H.ns_id.labels, idx - 1, 0, extmark_opts)
    end
    local submit = function()
      local key = vim.api.nvim_replace_termcodes("<cr>", true, false, true)
      vim.api.nvim_feedkeys(key, "n", false)
      vim.api.nvim_feedkeys("<Ignore>", "n", false) -- prevent extra cr cursor movement
    end

    H.clear_namespace(buf_id, H.ns_id.labels) -- remove virtual clues and hl
    local use_hotkey = runtime_vars.use_hotkey
    for i, item_displayed in ipairs(items) do
      if i > nr_of_labels then break end -- item can't have a label
      add_clues(i, item_displayed, use_hotkey and #query == 0 and "MiniPickMatchRanges" or "Comment")
    end
    if use_hotkey and #query == 1 and vim.tbl_contains(vim.tbl_keys(runtime_vars.labels_to_items), query[1]) then
      submit()
    end
  end
end

H.make_override_start = function(start_orig)
  return function(opts)
    Pick.start = start_orig -- Picker started, restore original
    local runtime_vars = {
      items = {}, -- Pick.get_picker_items returns a deepcopy, preventing simple equality test
      use_hotkey = false, -- Only when all items are labeled a hotkey can be used
      labels_to_items = {}, -- Key is the label, value is corresponding item
    }
    Pick.set_picker_items = H.make_override_set_items(Pick.set_picker_items, runtime_vars)
    opts.source.match = H.make_override_match(opts.source.match or Pick.default_match)
    opts.source.show = H.make_override_show(opts.source.show or Pick.default_show, runtime_vars)

    -- Invoke the original Pick.start:
    return start_orig(opts)
  end
end

H.make_labeled_ui_select = function()
  return function(items, opts, on_choice)
    -- Override Pick.start before picker_func executes:
    Pick.start = H.make_override_start(Pick.start)
    -- Invoke Pick.ui_select
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
    -- Override Pick.start before picker_func executes:
    Pick.start = H.make_override_start(Pick.start)
    -- Invoke the picker function:
    picker_func(local_opts, start_opts)
  end
end

-- POC: Override pickers defined in ak/config/editor/mini_pick.lua

-- The most relevant usage of labels in a picker...
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

Pick.registry.labeled_files = function(local_opts, opts)
  local picker_func = H.make_labeled(Pick.builtin.files)
  picker_func(local_opts, opts)
end

Pick.registry.labeled_ui_select = function(items, opts, on_choice)
  local picker_ui_select = H.make_labeled_ui_select()
  picker_ui_select(items, opts, on_choice)
end

local map = vim.keymap.set
map("n", "<leader>'", Pick.registry.labeled_buffers, { desc = "Labeled buffers pick", silent = true })
map(
  "n",
  "<leader>b",
  function() Pick.registry.labeled_lsp({ scope = "document_symbol" }, {}) end,
  { desc = "Labeled buffer symbols", silent = true }
)
map(
  "n",
  "<leader>r",
  function() Pick.registry.labeled_oldfiles({ current_dir = true }, {}) end,
  { desc = "Labeled recent (rel)", silent = true }
)
map("n", "<leader>ff", Pick.registry.labeled_files, { desc = "Labeled files", silent = true })
map("n", "<leader>fU", function()
  vim.ui.select = Pick.registry.labeled_ui_select -- Pick.ui_select
  local hello = "Hello"
  vim.ui.select({ hello, "Helloo", "Hellooo", "Helloooo", "Hellooooo", "Helloooooo" }, {
    prompt = "Choose your Hello version",
  }, function(choice)
    if not choice then return end
    hello = choice
  end)
  vim.notify(hello)
end, { desc = "Labeled files", silent = true })
-- Pick.setup({})
