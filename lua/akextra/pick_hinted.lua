---@diagnostic disable: undefined-global
-- "Picker with hints" feature. See https://github.com/echasnovski/mini.nvim/discussions/1109
-- Useful when:
-- 1. Picker has limited items (ie buffers, ui_select: hotkeys activated)
-- 2. Picker displays most valuable results on top(ie oldfiles, visits)
-- Less useful: Pick.files, top results have no extra meaning
--
-- Requirements:
-- 1. MiniPick active

-- Config to merge into MiniPick.start(opts)
-- Override by providing (parts of) the config to opts:
-- 1. Pick.start(opts)
-- 2. SomePicker(local_opts, opts)
local config = {
  hinted = {
    enable = false, -- opt-in per picker
    chars = vim.split('adefhilmnorstu', ''),
    virt_clues_pos = { 'eol' }, -- or { "inline", "eol" }, { "eol "}
    use_autosubmit = false, -- opt-in to autosubmit per picker
  },
}
local ns_id = { hinted = vim.api.nvim_create_namespace('PickHinted') }
local keys = {
  cr = vim.api.nvim_replace_termcodes('<CR>', true, true, true),
}

-- Copied from mini.pick:
local clear_namespace = function(buf_id, ns_id) pcall(vim.api.nvim_buf_clear_namespace, buf_id, ns_id, 0, -1) end
local set_extmark = function(...) pcall(vim.api.nvim_buf_set_extmark, ...) end
-- End copied from mini.pick

local invert = function(tbl_in)
  local tbl_out = {}
  -- stylua: ignore
  for idx, l in ipairs(tbl_in) do tbl_out[l] = idx end
  return tbl_out
end

local make_override_match = function(match, ctx, picker_opts)
  local hinted_chars_inv = invert(picker_opts.hinted.chars)

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
    stritems[hinted_index] = string.format('%s%s', char, stritems[hinted_index]) -- ensure item is matched
    local result = match(stritems, inds, query, opts)
    local matches = MiniPick.get_picker_matches() or {} -- ensure item is current
    if hinted_index ~= matches.current_ind then MiniPick.set_picker_match_inds({ hinted_index }, 'current') end
    ctx.hinted_index = hinted_index
    return result
  end
end

local add_hints = function(buf_id, max_hints, do_autosubmit, picker_opts)
  local hl = do_autosubmit and 'MiniPickMatchRanges' or 'Comment'
  for i, hint in ipairs(picker_opts.hinted.chars) do
    if i > max_hints then break end
    local virt_text = { { string.format('[%s]', hint), hl } }
    local extmark_opts = { hl_mode = 'combine', priority = 200, virt_text = virt_text }

    -- Add hint to start or end of line, or both:
    for _, virt_text_pos in ipairs(picker_opts.hinted.virt_clues_pos) do
      extmark_opts.virt_text_pos = virt_text_pos
      set_extmark(buf_id, ns_id.hinted, i - 1, 0, extmark_opts)
    end
  end
end

local init_show_ctx = function(items, ctx, picker_opts)
  if not ctx.max_hints then ctx.max_hints = math.min(#picker_opts.hinted.chars, #items) end
  local all_items = MiniPick.get_picker_items() or {}

  local result = {}
  result.first_item = items[1] or {}
  result.do_autosubmit = ctx.use_autosubmit and #all_items == ctx.max_hints
  result.did_autosubmit = false

  return result
end

local make_override_show = function(show, ctx, picker_opts)
  local show_ctx
  return function(buf_id, items, query, opts) -- items contain as many as displayed
    if not show_ctx then show_ctx = init_show_ctx(items, ctx, picker_opts) end
    clear_namespace(buf_id, ns_id.hinted) -- remove hints

    -- No hint, create hints if applicable
    if ctx.hinted_index == nil then
      show(buf_id, items, query, opts)
      if #query == 0 and show_ctx.first_item == items[1] then
        -- Only add hints when query is empty and window is not scrolled
        add_hints(buf_id, ctx.max_hints, show_ctx.do_autosubmit, picker_opts)
      end
      return
    end

    -- Valid hint
    if show_ctx.do_autosubmit then -- autosubmit
      if not show_ctx.did_autosubmit then
        show_ctx.did_autosubmit = true
        vim.api.nvim_feedkeys(keys.cr, 'n', true)
      end
      return
    end
    show(buf_id, items, query, opts) -- no autosubmit
  end
end

local on_pick_start_event = function()
  local picker_opts = vim.tbl_deep_extend('force', config, MiniPick.get_picker_opts() or {})
  if not picker_opts.hinted.enable then return end -- opt-in per picker...

  local use_autosubmit = picker_opts.hinted.use_autosubmit
  local runtime_ctx = { hinted_index = nil, max_hints = nil, use_autosubmit = use_autosubmit }
  local src = picker_opts.source
  src.match = make_override_match(src.match, runtime_ctx, picker_opts)
  src.show = make_override_show(src.show, runtime_ctx, picker_opts)
  MiniPick.set_picker_opts(picker_opts)
end

-- Enable hints in pickers
-- Opt-in, add "hinted = { enable = true }" to opts:
-- 1. MiniPick.start(opts)
-- 2. SomePicker(local_opts, opts)
local PickHinted = {}
PickHinted.setup = function()
  _G.PickHinted = PickHinted
  local augroup = vim.api.nvim_create_augroup('PickHinted', {})
  local au = function(event, pattern, callback, desc)
    vim.api.nvim_create_autocmd(event, { group = augroup, pattern = pattern, callback = callback, desc = desc })
  end
  au('User', 'MiniPickStart', on_pick_start_event, 'Augment pickers with hints')
end
return PickHinted
