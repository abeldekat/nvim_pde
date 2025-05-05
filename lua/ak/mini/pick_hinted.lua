-- "Picker with hints" feature. See https://github.com/echasnovski/mini.nvim/discussions/1109
-- Useful when:
-- 1. Picker has limited items (ie buffers, ui_select: hotkeys activated)
-- 2. Picker displays most valuable results on top(ie oldfiles, visits)
-- Less useful: Pick.files, top results have no extra meaning
--
-- Requirements:
-- 1. MiniPick active

local PickHinted = {}
local H = {}

-- Enable hints in pickers
-- Opt-in, add "hinted = { enable = true }" to opts:
-- 1. MiniPick.start(opts)
-- 2. SomePicker(local_opts, opts)
PickHinted.setup = function(config)
  _G.PickHinted = PickHinted
  config = H.setup_config(config)
  H.apply_config(config)
  H.create_autocommands()
end

-- Provide a default to merge into MiniPick.start(opts)
-- Override by providing (parts of) the config to opts:
-- 1. Pick.start(opts)
-- 2. SomePicker(local_opts, opts)
PickHinted.config = {
  hinted = {
    enable = false, -- opt-in
    chars = vim.split("abcdefghijklmnopqrstuvwxyz", ""),
    virt_clues_pos = { "eol" }, -- or { "inline", "eol" }, { "eol "}
    use_autosubmit = false, -- if possible, use autosubmit
  },
}

-- Helper ================================================================

H.default_config = vim.deepcopy(PickHinted.config)
H.ns_id = { hinted = vim.api.nvim_create_namespace("PickHinted") }
H.keys = {
  cr = vim.api.nvim_replace_termcodes("<CR>", true, true, true),
}

H.is_list_of = function(x, x_name, type_to_test)
  if not vim.islist(x) then return false, string.format("`%s` should be a list.", x_name) end
  for key, value in ipairs(x) do
    if type(value) ~= type_to_test then
      return false, string.format("`%s[%s]` should be a %s.", x_name, vim.inspect(key), type_to_test)
    end
  end
  return true, ""
end

H.setup_config = function(config)
  vim.validate({
    MiniPick = { MiniPick, "table" },
    config = { config, "table" },
  })
  config = vim.tbl_deep_extend("force", vim.deepcopy(H.default_config), config or {})

  vim.validate({ [config.hinted] = { config.hinted, "table" } })
  vim.validate({
    ["hinted.enable"] = { config.hinted.enable, "boolean" },
    ["hinted.chars"] = { config.hinted.chars, function(x) return H.is_list_of(x, "hinted.chars", "string") end },
    ["hinted.virt_clues_pos"] = {
      config.hinted.virt_clues_pos,
      function(x) return H.is_list_of(x, "hinted.virt_clues_pos", "string") end,
    },
    ["hinted.use_autosubmit"] = { config.hinted.use_autosubmit, "boolean" },
  })
  return config
end

H.apply_config = function(config) PickHinted.config = config end

H.get_config = function()
  -- No buffer override: vim.b.akminipickhinted or {}
  -- No config arg
  -- return vim.tbl_deep_extend("force", PickHinted.config or {}, config or {})
  return PickHinted.config
end

H.create_autocommands = function()
  local augroup = vim.api.nvim_create_augroup("mini-ak-pick-hinted", { clear = true })
  local au = function(event, pattern, callback, desc)
    vim.api.nvim_create_autocmd(event, { group = augroup, pattern = pattern, callback = callback, desc = desc })
  end
  au("User", "MiniPickStart", H.on_pick_start_event, "Augment pickers with hints")
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
  local hinted_chars_inv = H.invert(picker_opts.hinted.chars)

  -- premisse: items and stritems are constant and related, having the same ordering and length.
  return function(stritems, inds, query, opts)
    -- Restore previously modified stritem if present
    if ctx.hinted_index then stritems[ctx.hinted_index] = string.sub(stritems[ctx.hinted_index], 2) end
    ctx.hinted_index = nil

    -- No hint: Query only holds a potential hint when it contains 1 single char
    if #query ~= 1 then return match(stritems, inds, query, opts) end

    -- Find index of potential hint
    local char = query[1]
    local hinted_index = hinted_chars_inv[char]
    if not hinted_index or hinted_index > ctx.max_hints then return match(stritems, inds, query, opts) end

    -- Valid hint
    stritems[hinted_index] = string.format("%s%s", char, stritems[hinted_index]) -- ensure item is matched
    local result = match(stritems, inds, query, opts)
    local matches = MiniPick.get_picker_matches() or {} -- ensure item is current
    if hinted_index ~= matches.current_ind then MiniPick.set_picker_match_inds({ hinted_index }, "current") end
    ctx.hinted_index = hinted_index
    return result
  end
end

H.add_hints = function(buf_id, max_hints, do_autosubmit, picker_opts)
  local hl = do_autosubmit and "MiniPickMatchRanges" or "Comment"
  for i, hint in ipairs(picker_opts.hinted.chars) do
    if i > max_hints then break end
    local virt_text = { { string.format("[%s]", hint), hl } }
    local extmark_opts = { hl_mode = "combine", priority = 200, virt_text = virt_text }

    -- Add hint to start or end of line, or both:
    for _, virt_text_pos in ipairs(picker_opts.hinted.virt_clues_pos) do
      extmark_opts.virt_text_pos = virt_text_pos
      H.set_extmark(buf_id, H.ns_id.hinted, i - 1, 0, extmark_opts)
    end
  end
end

H.init_show_ctx = function(items, ctx, picker_opts)
  if not ctx.max_hints then ctx.max_hints = math.min(#picker_opts.hinted.chars, #items) end
  local all_items = MiniPick.get_picker_items() or {}

  local result = {}
  result.first_item = items[1] or {}
  result.do_autosubmit = ctx.use_autosubmit and #all_items == ctx.max_hints
  result.did_autosubmit = false

  return result
end

H.make_override_show = function(show, ctx, picker_opts)
  local show_ctx
  return function(buf_id, items, query, opts) -- items contain as many as displayed
    if not show_ctx then show_ctx = H.init_show_ctx(items, ctx, picker_opts) end
    H.clear_namespace(buf_id, H.ns_id.hinted) -- remove hints

    -- No hint, create hints if applicable
    if ctx.hinted_index == nil then
      show(buf_id, items, query, opts)
      if #query == 0 and show_ctx.first_item == items[1] then
        -- Only add hints when query is empty and window is not scrolled
        H.add_hints(buf_id, ctx.max_hints, show_ctx.do_autosubmit, picker_opts)
      end
      return
    end

    -- Valid hint
    if show_ctx.do_autosubmit then -- autosubmit
      if not show_ctx.did_autosubmit then
        show_ctx.did_autosubmit = true
        vim.api.nvim_feedkeys(H.keys.cr, "n", true)
      end
      return
    end
    show(buf_id, items, query, opts) -- no autosubmit
  end
end

H.on_pick_start_event = function()
  local picker_opts = vim.tbl_deep_extend("force", H.get_config(), MiniPick.get_picker_opts() or {})
  if not picker_opts.hinted.enable then return end -- opt-in per picker...

  local use_autosubmit = picker_opts.hinted.use_autosubmit
  local runtime_ctx = { hinted_index = nil, max_hints = nil, use_autosubmit = use_autosubmit }
  local src = picker_opts.source
  src.match = H.make_override_match(src.match, runtime_ctx, picker_opts)
  src.show = H.make_override_show(src.show, runtime_ctx, picker_opts)
  MiniPick.set_picker_opts(picker_opts)
end

return PickHinted
