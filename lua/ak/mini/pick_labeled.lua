-- "Labeled Picker" feature.
-- Useful when:
-- 1. Picker has limited items (ie buffers, ui_select: hotkeys activated)
-- 2. Picker displays most valuable results on top(ie oldfiles, visits)
-- Less useful: Pick.files, top results have no extra meaning

local PickLabeled = {}
local H = {}

PickLabeled.setup = function(config)
  if not MiniPick then return end

  _G.PickLabeled = PickLabeled
  config = H.setup_config(config)
  H.apply_config(config)
  H.create_autocommands(config)
end

PickLabeled.config = {
  labeled = {
    chars = vim.split("abcdefghijklmnopqrstuvwxyz", ""),
    virt_clues_pos = { "eol" }, -- or { "inline", "eol" }, { "eol "}
    use_autosubmit = true, -- if possible, use autosubmit
  },
}

PickLabeled.ui_select = function(items, opts, on_choice)
  if not opts.prompt then opts.prompt = "Select one of:" end
  opts.prompt = string.format("%s%s", H.ui_select_marker, opts.prompt)
  MiniPick.ui_select(items, opts, on_choice)
end

-- Helper ================================================================

H.default_config = vim.deepcopy(PickLabeled.config)
H.ns_id = { labeled = vim.api.nvim_create_namespace("MiniExtraLabeledPick") } -- clues
H.ui_select_marker = "+ELP+"

H.setup_config = function(config)
  config = vim.tbl_deep_extend("force", vim.deepcopy(H.default_config), config or {})
  -- TODO: vim.validate
  return config
end

H.apply_config = function(config) PickLabeled.config = config end

H.get_config = function(config)
  -- return vim.tbl_deep_extend("force", PickLabeled.config, vim.b.mini_ak.pick_labeled_config or {}, config or {})
  return vim.tbl_deep_extend("force", PickLabeled.config or {}, config or {})
end

H.create_autocommands = function(_) -- config
  local augroup = vim.api.nvim_create_augroup("mini-ak-pick-labeled", { clear = true })
  local au = function(event, pattern, callback, desc)
    vim.api.nvim_create_autocmd(event, { group = augroup, pattern = pattern, callback = callback, desc = desc })
  end
  au("User", "MiniPickStart", H.on_pick_start_event, "Augment pickers with labels")
end

-- Copied from mini.pick:
H.clear_namespace = function(buf_id, ns_id) pcall(vim.api.nvim_buf_clear_namespace, buf_id, ns_id, 0, -1) end

-- Copied from mini.pick:
H.set_extmark = function(...) pcall(vim.api.nvim_buf_set_extmark, ...) end

H.invert = function(tbl_in)
  local tbl_out = {}
  -- stylua: ignore
  for idx, l in ipairs(tbl_in) do tbl_out[l] = idx end
  return tbl_out
end

H.make_override_match = function(match, ctx, picker_opts)
  local labeled_chars_inv = H.invert(picker_opts.labeled.chars)

  -- premisse: items and stritems are constant and related, having the same ordering and length.
  return function(stritems, inds, query, do_sync)
    -- Restore previously modified stritem if present
    if ctx.labeled_ind then stritems[ctx.labeled_ind] = string.sub(stritems[ctx.labeled_ind], 2) end
    ctx.labeled_ind = nil

    -- Query only holds a potential label when it contains 1 single char
    if #query ~= 1 then return match(stritems, inds, query, do_sync) end

    -- Find index of potential label
    local char = query[1]
    local labeled_ind = labeled_chars_inv[char]
    if not labeled_ind or labeled_ind > ctx.max_labels then return match(stritems, inds, query, do_sync) end

    -- Valid label: Make sure the item is matched
    ctx.labeled_ind = labeled_ind
    stritems[labeled_ind] = string.format("%s%s", char, stritems[labeled_ind])
    return match(stritems, inds, query, do_sync)
  end
end

H.autosubmit = function()
  local enter_key = vim.api.nvim_replace_termcodes("<cr>", true, true, true)

  vim.api.nvim_feedkeys(enter_key, "n", false)
  vim.api.nvim_feedkeys("<Ignore>", "n", false)
end

H.add_clues = function(buf_id, max_labels, autosubmit, picker_opts)
  local hl = autosubmit and "MiniPickMatchRanges" or "Comment"
  for i, label in ipairs(picker_opts.labeled.chars) do
    if i > max_labels then break end
    local virt_text = { { string.format("[%s]", label), hl } }
    local extmark_opts = { hl_mode = "combine", priority = 200, virt_text = virt_text }

    -- Add clue to start or end of line, or both:
    for _, virt_text_pos in ipairs(picker_opts.labeled.virt_clues_pos) do
      extmark_opts.virt_text_pos = virt_text_pos
      H.set_extmark(buf_id, H.ns_id.labeled, i - 1, 0, extmark_opts)
    end
  end
end

H.make_show_ctx = function(items, ctx, picker_opts)
  if not ctx.max_labels then ctx.max_labels = math.min(#picker_opts.labeled.chars, #items) end
  local all_items = MiniPick.get_picker_items() or {}

  local result = {}
  result.first_item = items[1] or {}
  result.autosubmit = picker_opts.labeled.use_autosubmit and #all_items == ctx.max_labels

  return result
end

H.set_labeled_as_first_item = function(all_inds, labeled_ind)
  local labeled_ind_pos
  for i, ind in ipairs(all_inds) do
    if ind == labeled_ind then
      labeled_ind_pos = i
      break
    end
  end
  table.remove(all_inds, labeled_ind_pos)
  table.insert(all_inds, 1, labeled_ind)
  MiniPick.set_picker_match_inds(all_inds)
end

H.make_override_show = function(show, ctx, picker_opts)
  local show_ctx
  return function(buf_id, items, query, opts) -- items contain as many as displayed
    if not show_ctx then show_ctx = H.make_show_ctx(items, ctx, picker_opts) end
    H.clear_namespace(buf_id, H.ns_id.labeled) -- remove clues

    -- Query does not contain a valid label
    if not ctx.labeled_ind then
      show(buf_id, items, query, opts)

      -- Only add clues when query is empty and window is not scrolled
      if #query == 0 and show_ctx.first_item == items[1] then
        H.add_clues(buf_id, ctx.max_labels, show_ctx.autosubmit, picker_opts)
      end
      return
    end

    -- Query contains valid label. Make sure item is first in the list
    local all_inds = (MiniPick.get_picker_matches() or {}).all_inds
    if ctx.labeled_ind ~= all_inds[1] then
      H.set_labeled_as_first_item(all_inds, ctx.labeled_ind)
      return
    end

    -- Either autosubmit labeled item or show items with item first in the list
    if show_ctx.autosubmit then
      H.autosubmit()
    else
      show(buf_id, items, query, opts)
    end
  end
end

H.on_pick_start_event = function()
  local picker_opts = vim.tbl_deep_extend("force", H.get_config(), MiniPick.get_picker_opts() or {})
  local use = picker_opts.use_labels -- opt-in per picker...
  local src = picker_opts.source
  if use == nil and string.sub(src.name, 1, #H.ui_select_marker) == H.ui_select_marker then
    src.name = string.sub(src.name, #H.ui_select_marker + 1)
    use = true -- vim.ui.select is set to Extra.pickers.labeled_ui_select
  end
  if not use then return end

  local runtime_ctx = { labeled_ind = nil, max_labels = nil }
  src.match = H.make_override_match(src.match, runtime_ctx, picker_opts)
  src.show = H.make_override_show(src.show, runtime_ctx, picker_opts)
  MiniPick.set_picker_opts(picker_opts)
end

return PickLabeled
