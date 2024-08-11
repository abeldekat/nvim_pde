local Pick = require("mini.pick")
local Extra = require("mini.extra")

-- Helper data ================================================================

-- ELP: "Extra Labeled Picker" feature. Has similar purpose as "H = {}" in mini.extra
-- Useful when: Picker has limited items (ie buffers, ui_select: hotkeys activated)
-- Useful when: Picker displays most valuable results on top(ie oldfiles, visits)
-- Less useful: Pick.files, top results have no extra meaning
local ELP = {}

ELP.labels = vim.split("abcdefghijklmnopqrstuvwxyz", "") -- configurable
ELP.virt_clues_pos = { "eol" } -- configurable { "inline" }, { "inline", "eol"}

ELP.invert = function(tbl_in)
  local tbl_out = {}
  -- stylua: ignore
  for idx, l in ipairs(tbl_in) do tbl_out[l] = idx end
  return tbl_out
end
ELP.labels_inv = ELP.invert(ELP.labels)
ELP.ns_id = { labels = vim.api.nvim_create_namespace("MiniExtraLabeledPick") } -- clues
ELP.ui_select_marker = "+ELP+"

-- Copied from mini.pick:
ELP.clear_namespace = function(buf_id, ns_id) pcall(vim.api.nvim_buf_clear_namespace, buf_id, ns_id, 0, -1) end
ELP.set_extmark = function(...) pcall(vim.api.nvim_buf_set_extmark, ...) end

ELP.make_override_match = function(match, picker_ctx)
  -- premisse: items and stritems are constant and related, having the same ordering and length.
  return function(stritems, inds, query, do_sync)
    -- Restore previously modified stritem if present
    if picker_ctx.labeled_ind then
      stritems[picker_ctx.labeled_ind] = string.sub(stritems[picker_ctx.labeled_ind], 2)
    end
    picker_ctx.labeled_ind = nil

    -- Query only holds a potential label when it contains 1 single char
    if #query ~= 1 then return match(stritems, inds, query, do_sync) end

    -- Find index of potential label
    local char = query[1]
    local labeled_ind = ELP.labels_inv[char]
    if not labeled_ind or labeled_ind > picker_ctx.max_labels then return match(stritems, inds, query, do_sync) end

    -- Valid label: Make sure the item is matched
    picker_ctx.labeled_ind = labeled_ind
    stritems[labeled_ind] = string.format("%s%s", char, stritems[labeled_ind])
    return match(stritems, inds, query, do_sync)
  end
end

ELP.autosubmit = function()
  local enter_key = vim.api.nvim_replace_termcodes("<cr>", true, true, true)

  vim.api.nvim_feedkeys(enter_key, "n", false)
  vim.api.nvim_feedkeys("<Ignore>", "n", false)
end

ELP.add_clues = function(buf_id, max_labels, autosubmit)
  local hl = autosubmit and "MiniPickMatchRanges" or "Comment"
  for i, label in ipairs(ELP.labels) do
    if i > max_labels then break end
    local virt_text = { { string.format("[%s]", label), hl } }
    local extmark_opts = { hl_mode = "combine", priority = 200, virt_text = virt_text }

    -- Add clue to start or end of line, or both:
    for _, virt_text_pos in ipairs(ELP.virt_clues_pos) do
      extmark_opts.virt_text_pos = virt_text_pos
      ELP.set_extmark(buf_id, ELP.ns_id.labels, i - 1, 0, extmark_opts)
    end
  end
end

ELP.make_initial_ctx = function(items, picker_ctx)
  if not picker_ctx.max_labels then picker_ctx.max_labels = math.min(#ELP.labels, #items) end
  local all_items = Pick.get_picker_items() or {}

  local ctx = {}
  ctx.first_item = items[1] or {}
  ctx.autosubmit = #all_items == picker_ctx.max_labels
  return ctx
end

ELP.set_labeled_as_first_item = function(all_inds, labeled_ind)
  local labeled_ind_pos
  for i, ind in ipairs(all_inds) do
    if ind == labeled_ind then
      labeled_ind_pos = i
      break
    end
  end
  table.remove(all_inds, labeled_ind_pos)
  table.insert(all_inds, 1, labeled_ind)
  Pick.set_picker_match_inds(all_inds)
end

ELP.make_override_show = function(show, picker_ctx)
  local ctx
  return function(buf_id, items, query, opts) -- items contain as many as displayed
    if not ctx then ctx = ELP.make_initial_ctx(items, picker_ctx) end
    ELP.clear_namespace(buf_id, ELP.ns_id.labels) -- remove clues

    -- Query does not contain a valid label
    if not picker_ctx.labeled_ind then
      show(buf_id, items, query, opts)

      -- Only add clues when query is empty and window is not scrolled
      if #query == 0 and ctx.first_item == items[1] then
        ELP.add_clues(buf_id, picker_ctx.max_labels, ctx.autosubmit)
      end
      return
    end

    -- Query contains valid label. Make sure item is first in the list
    local all_inds = (Pick.get_picker_matches() or {}).all_inds
    if picker_ctx.labeled_ind ~= all_inds[1] then
      ELP.set_labeled_as_first_item(all_inds, picker_ctx.labeled_ind)
      return
    end

    -- Either autosubmit labeled item or show items with item first in the list
    if ctx.autosubmit then
      ELP.autosubmit()
    else
      show(buf_id, items, query, opts)
    end
  end
end

ELP.on_pick_start_event = function()
  local opts = Pick.get_picker_opts()
  if not opts then return end

  local label = opts.label
  local src = opts.source
  if label == nil and string.sub(src.name, 1, #ELP.ui_select_marker) == ELP.ui_select_marker then
    src.name = string.sub(src.name, #ELP.ui_select_marker + 1)
    label = true -- vim.ui.select is set to Extra.pickers.labeled_ui_select
  end
  if not label then return end

  local picker_ctx = { labeled_ind = nil, max_labels = nil }
  src.match = ELP.make_override_match(src.match, picker_ctx)
  src.show = ELP.make_override_show(src.show, picker_ctx)
  Pick.set_picker_opts(opts)
end

-- Public  ================================================================

-- Take opts.label into account and override opts.source.{match, show, choose}
Extra.pickers_enable_label_in_options = function()
  local group = vim.api.nvim_create_augroup("miniextra-labeled-pick", { clear = true })
  vim.api.nvim_create_autocmd("User", {
    pattern = "MiniPickStart",
    group = group,
    desc = "Augment pickers with labels",
    callback = ELP.on_pick_start_event,
  })
end

Extra.pickers.labeled_ui_select = function(items, opts, on_choice)
  if not opts.prompt then opts.prompt = "Select one of:" end -- explicitly set default
  opts.prompt = string.format("%s%s", ELP.ui_select_marker, opts.prompt)
  Pick.ui_select(items, opts, on_choice)
end

-- POC ================================================================

local make_centered_window = function() -- copied from :h MiniPick
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

Extra.pickers_enable_label_in_options()
vim.ui.select = Extra.pickers.labeled_ui_select
local map = vim.keymap.set

local files = function() Pick.builtin.files() end
map("n", "<leader><leader>", files, { desc = "Files pick" })

local labeled_buffers = function()
  local show_icons = true
  local source = { show = not show_icons and Pick.default_show or nil }
  local window = true and make_centered_window() or nil
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
local select_hello = function() vim.ui.select({ "Hello", "Helloooo", "Helloooooo" }, { prompt = "Say hi" }, on_choice) end
map("n", "<leader>fy", select_hello, { desc = "Labeled ui select", silent = true })

-- Pick.setup()
