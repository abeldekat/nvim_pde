-- UI consists from a single window capable of displaying three different views:
-- - "Main" - where current query matches are shown.
-- - "Preview" - preview of current item (toggle with `<Tab>`).
-- - "Info" - general info about picker and its state (toggle with `<S-Tab>`).

-- - If query starts with `'`, the match is exact.
-- - If query starts with `^`, the match is exact at start.
-- - If query ends with `$`, the match is exact at end.
-- - If query starts with `*`, the match is forced to be fuzzy.
-- - Otherwise match is fuzzy.
-- - Sorting is done to first minimize match width and then match start.
--   Nothing more: no favoring certain places in string, etc.

-- Manpages, autocommands and quickfixhis: Use fzf-lua builtin
-- Paths: No filename first option

local Utils = require("ak.util")
local Pick = require("mini.pick")
local Extra = require("mini.extra")

-- Helper data ================================================================

local H = {} -- Helper functions

---@type table<string,function>  event MiniPickStart
H.start_hooks = {}
---@type table<string,function> event MiniPickStop
H.stop_hooks = {}

H.setup_autocommands = function()
  local group = vim.api.nvim_create_augroup("minipick-custom-hooks", { clear = true })
  local function au(pattern, desc, hooks)
    vim.api.nvim_create_autocmd({ "User" }, {
      pattern = pattern,
      group = group,
      desc = desc,
      callback = function(...)
        local opts = Pick.get_picker_opts() or {}
        if opts and opts.source then
          local hook = hooks[opts.source.name] or function(...) end
          hook(...)
        end
      end,
    })
  end
  au("MiniPickStart", "Picker start hook for source.name", H.start_hooks)
  au("MiniPickStop", "Picker stop hook for source.name", H.stop_hooks)
end

H.colors = function()
  -- stylua: ignore
  local builtins = { -- source code telescope.nvim ignore_builtins
      "blue", "darkblue", "default", "delek", "desert", "elflord", "evening",
      "habamax", "industry", "koehler", "lunaperche", "morning", "murphy",
      "pablo", "peachpuff", "quiet", "retrobox", "ron", "shine", "slate",
      "sorbet", "torte", "vim", "wildcharm", "zaibatsu", "zellner",
  }

  return vim.tbl_filter(
    function(color) return not vim.tbl_contains(builtins, color) end, --
    vim.fn.getcompletion("", "color")
  )
end

H.bdir = function() -- note: in oil dir, return nil and fallback to root cwd
  if vim["bo"].buftype == "" then return vim.fn.expand("%:p:h") end
end

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

-- EPL: "Extra Labeled Picker"" feature. Has similar purpose as "H = {}" in mini.extra
-- Useful when: Picker has limited items (ie buffers, ui_select: hotkeys activated)
-- Useful when: Picker displays most valuable results on top(ie oldfiles, visits)
-- Less useful: Pick.files, top results have no extra meaning
--
-- Edge cases that are hard to fix:
-- 1:
-- a. Pick buffers, labeled, lots of buffers starting with "lua", autosubmit is not active
-- b. Press label 'l'(also first letter of "lua")
-- c  Note that the labeled item is -not- placed as first item in the list
-- d. Press enter
-- e.  Note that the labeled item is opened correctly, instead of the first item displayed
--
local EPL = {}

EPL.invert = function(tbl_in)
  local tbl_out = {}
  -- stylua: ignore
  for idx, l in ipairs(tbl_in) do tbl_out[l] = idx end
  return tbl_out
end
EPL.labels = vim.split("abcdefghijklmnopqrstuvwxyz", "")
EPL.labels_inv = EPL.invert(EPL.labels)
EPL.ns_id = { labels = vim.api.nvim_create_namespace("MiniExtraLabeledPick") } -- clues

-- Copied from mini.pick:
EPL.clear_namespace = function(buf_id, ns_id) pcall(vim.api.nvim_buf_clear_namespace, buf_id, ns_id, 0, -1) end
EPL.set_extmark = function(...) pcall(vim.api.nvim_buf_set_extmark, ...) end
EPL.ui_select_marker = function() end

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
      local extmark_opts = { hl_mode = "combine", priority = 200, virt_text = virt_text }

      -- Add clue to start or end of line, or both:
      for _, virt_text_pos in ipairs({ "eol" }) do -- { "inline", "eol" }
        extmark_opts.virt_text_pos = virt_text_pos
        EPL.set_extmark(buf_id, EPL.ns_id.labels, i - 1, 0, extmark_opts)
      end
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

-- Extra: Implements feature adding labels to pickers  ======================================================

-- Take opts = { label = true } into account and  override opts.source.{match, show, choose}
Extra.pickers_enable_label_in_options = function()
  local group = vim.api.nvim_create_augroup("miniextra-labeled-pick", { clear = true })
  vim.api.nvim_create_autocmd("User", {
    pattern = "MiniPickStart",
    group = group,
    desc = "Augment pickers with labels",
    callback = function()
      local opts = Pick.get_picker_opts()
      if not opts then return end

      local should_label = opts.label
      if should_label == nil and vim.ui.select == EPL.ui_select_marker then should_label = true end
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

Extra.pickers.labeled_ui_select = function(items, opts, on_choice)
  local ui_select_org = vim.ui.select
  vim.ui.select = EPL.ui_select_marker
  Pick.ui_select(items, opts, on_choice)
  vim.ui.select = ui_select_org
end

-- Custom pickers  ================================================================

-- https://github.com/echasnovski/mini.nvim/discussions/518#discussioncomment-7373556
-- Implements: For TODOs in a project, use builtin.grep.
-- Note: label is possible, but prevents preview on other items
Pick.registry.todo_comments = function(patterns) --hipatterns.config.highlighters
  local function find_todo(item)
    for _, hl in pairs(patterns) do
      local pattern = hl.pattern:sub(2) -- remove the prepending space
      if item:find(pattern, 1, true) then return hl end
    end
    return patterns[1] -- prevent nil
  end
  local change_display = function(items)
    return vim.tbl_map(function(item)
      local s = string.gsub(item, "│", "") -- remove character used by comment box
      s = string.gsub(s, "%s+", " ") -- change multiple spaces into one space
      local todo = find_todo(s).pattern:sub(1, -2) -- remove the : to prevent hl on first col
      return todo .. " " .. s
    end, items)
  end
  local search_regex = function(keywords)
    local pattern = [[\b(KEYWORDS):]]
    local upper = vim.tbl_filter(function(keyword)
      local match = string.match(keyword, "^%u+$")
      return match and true or false
    end, keywords)
    return pattern:gsub("KEYWORDS", table.concat(upper, "|"))
  end
  local on_start = function()
    if MiniHipatterns then MiniHipatterns.enable(vim.api.nvim_get_current_buf()) end
  end
  local show = function(buf_id, items, query)
    Pick.default_show(buf_id, change_display(items), query, { show_icons = true }) --
  end

  local name = "Todo-comments"
  if H.start_hooks[name] == nil then H.start_hooks[name] = on_start end
  Pick.builtin.grep(
    { tool = "rg", pattern = search_regex(vim.tbl_keys(patterns)) },
    { source = { name = name, show = show } }
  )
end

-- https://github.com/echasnovski/mini.nvim/discussions/951
-- Previewing multiple themes:
-- Press tab for preview, and continue with ctrl-n and ctrl-p
-- Note: label is possible, but most relevant items are not on top
local selected_colorscheme = nil
Pick.registry.colors = function()
  local on_start = function()
    selected_colorscheme = vim.g.colors_name --
  end
  local on_stop = function()
    vim.schedule(function() vim.cmd.colorscheme(selected_colorscheme) end)
  end

  local name = "Colors with preview"
  if H.start_hooks[name] == nil then H.start_hooks[name] = on_start end
  if H.stop_hooks[name] == nil then H.stop_hooks[name] = on_stop end
  return MiniPick.start({
    label = true,
    source = {
      name = name,
      items = H.colors(),
      choose = function(item) selected_colorscheme = item end,
      preview = function(buf_id, item)
        vim.cmd.colorscheme(item)
        vim.api.nvim_buf_set_lines(buf_id, 0, -1, false, { item })
      end,
    },
  })
end

-- https://github.com/echasnovski/mini.nvim/discussions/988
-- Fuzzy search the current buffer with syntax highlighting
-- Last attempt: linenr as extmarks, but no MiniPickMatchRanges highlighting
local ns_digit_prefix = vim.api.nvim_create_namespace("cur-buf-pick-show")
Pick.registry.buffer_lines_current = function()
  local show_cur_buf_lines = function(buf_id, items, query, opts)
    if items == nil or #items == 0 then return end

    -- Show as usual
    Pick.default_show(buf_id, items, query, opts)

    -- Move prefix line numbers into inline extmarks
    local lines = vim.api.nvim_buf_get_lines(buf_id, 0, -1, false)
    local digit_prefixes = {}
    for i, l in ipairs(lines) do
      local _, prefix_end, prefix = l:find("^(%d+│)")
      if prefix_end ~= nil then
        digit_prefixes[i], lines[i] = prefix, l:sub(prefix_end + 1)
      end
    end

    vim.api.nvim_buf_set_lines(buf_id, 0, -1, false, lines)
    for i, pref in pairs(digit_prefixes) do
      pref = string.sub(pref, 1, -4) -- Remove multi byte char "│"
      local extmark_opts = { virt_text = { { pref } }, virt_text_pos = "right_align" }
      vim.api.nvim_buf_set_extmark(buf_id, ns_digit_prefix, i - 1, 0, extmark_opts)
    end

    -- Set highlighting based on the curent filetype
    local ft = vim.bo[items[1].bufnr].filetype
    local has_lang, lang = pcall(vim.treesitter.language.get_lang, ft)
    local has_ts, _ = pcall(vim.treesitter.start, buf_id, has_lang and lang or ft)
    if not has_ts and ft then vim.bo[buf_id].syntax = ft end
  end
  MiniExtra.pickers.buf_lines({ scope = "current" }, { source = { show = show_cur_buf_lines } })
end

-- Apply  ================================================================

local cwd_cache = {}
local function files() -- either files or git_files
  local builtin = Pick.builtin
  local cwd = vim.uv.cwd()
  if cwd and cwd_cache[cwd] == nil then cwd_cache[cwd] = vim.uv.fs_stat(".git") and true or false end

  local opts = {}
  if cwd_cache[cwd] then opts.tool = "git" end
  builtin.files(opts)
end

local function provide_picker() -- picker to use in other modules
  local extra = MiniExtra.pickers
  local custom = Pick.registry

  ---@type Picker
  local Picker = {
    keymaps = extra.keymaps,

    -- mini.pick: no direct jump to definition(#978):
    lsp_definitions = function() vim.lsp.buf.definition({ reuse_win = true }) end,

    -- pickers.lsp does not add previous position to jumplist(#979):
    -- lsp_references = function() extra.lsp({ scope = "references" }) end,
    -- lsp_implementations = function() extra.lsp({ scope = "implementation" }) end,
    -- lsp_type_definitions = function() extra.lsp({ scope = "type_definition" }) end,
    lsp_references = function() vim.lsp.buf.references(nil, { reuse_win = true }) end,
    lsp_implementations = function() vim.lsp.buf.implementation({ reuse_win = true }) end,
    lsp_type_definitions = function() vim.lsp.buf.type_definition({ reuse_win = true }) end,

    colors = custom.colors,
    todo_comments = custom.todo_comments,
  }
  Utils.pick.use_picker(Picker)
end

local function keys()
  local function map(l, r, opts, mode)
    mode = mode or "n"
    opts["silent"] = opts.silent ~= false
    vim.keymap.set(mode, l, r, opts)
  end
  local builtin = Pick.builtin
  local extra = MiniExtra.pickers
  local custom = Pick.registry

  -- hotkeys:
  map("<leader><leader>", files, { desc = "Files pick" })
  map("<leader>/", custom.buffer_lines_current, { desc = "Buffer lines" })
  local labeled_buffers = function()
    local show_icons = true
    local source = { show = not show_icons and Pick.default_show or nil }
    local window = true and H.make_centered_window() or nil
    local opts = { label = true, source = source, window = window }
    builtin.buffers({}, opts)
  end
  map("<leader>;", labeled_buffers, { desc = "Buffers pick" }) -- home row, used often
  local labeled_symbols = function() extra.lsp({ scope = "document_symbol" }, { label = true }) end
  map("<leader>b", labeled_symbols, { desc = "Buffer symbols" })
  map("<leader>l", builtin.grep_live, { desc = "Live grep" })
  local labeled_oldfiles = function() extra.oldfiles({ current_dir = true }, { label = true }) end
  map("<leader>r", labeled_oldfiles, { desc = "Recent (rel)" })

  -- fuzzy main. Free: fe,fj,fn,fq,fv,fy
  map("<leader>f/", function() extra.history({ scope = "/" }) end, { desc = "'/' history" })
  local labeled_his_cmd = function() extra.history({ scope = ":" }, { label = true }) end
  map("<leader>f:", labeled_his_cmd, { desc = "':' history" })
  map("<leader>fa", function() extra.git_hunks({ scope = "staged" }) end, { desc = "Staged hunks" })
  local staged_buffer = function() extra.git_hunks({ path = vim.fn.expand("%"), scope = "staged" }) end
  map("<leader>fA", staged_buffer, { desc = "Staged hunks (current)" })
  map("<leader>fb", builtin.buffers, { desc = "Buffer pick" })
  map("<leader>fc", extra.git_commits, { desc = "Git commits" })
  map("<leader>fC", function() extra.git_commits({ path = vim.fn.expand("%") }) end, { desc = "Git commits buffer" })
  map("<leader>fd", function() extra.diagnostic({ scope = "current" }) end, { desc = "Diagnostic buffer" })
  map("<leader>fD", function() extra.diagnostic({ scope = "all" }) end, { desc = "Diagnostic workspace" })
  map("<leader>ff", files, { desc = "Files" })
  map("<leader>fF", function() builtin.files(nil, { source = { cwd = H.bdir() } }) end, { desc = "Files (rel)" })
  map("<leader>fg", builtin.grep_live, { desc = "Grep" })
  map("<leader>fG", function() builtin.grep_live(nil, { source = { cwd = H.bdir() } }) end, { desc = "Grep (rel)" })
  map("<leader>fh", builtin.help, { desc = "Help" })
  map("<leader>fi", function() vim.notify("No picker for fzf-lua builtin") end, { desc = "Fzf-lua builtin" })
  map("<leader>fk", extra.keymaps, { desc = "Key maps" })
  map("<leader>fl", custom.buffer_lines_current, { desc = "Buffer lines" })
  map("<leader>fL", function() extra.buf_lines() end, { desc = "Buffers lines" })
  map("<leader>fm", extra.git_hunks, { desc = "Unstaged hunks" })
  local git_hunks = function() extra.git_hunks({ path = vim.fn.expand("%") }) end
  map("<leader>fM", git_hunks, { desc = "Unstaged hunks (current)" })
  map("<leader>fp", extra.hipatterns, { desc = "Hipatterns" })
  map("<leader>fr", extra.oldfiles, { desc = "Recent" }) -- could also use fv fV for visits
  map("<leader>fR", function() extra.oldfiles({ current_dir = true }) end, { desc = "Recent (rel)" })
  map("<leader>fs", function() extra.lsp({ scope = "document_symbol" }) end, { desc = "Symbols buffer" })
  map("<leader>fS", function() extra.lsp({ scope = "workspace_symbol" }) end, { desc = "Symbols workspace" })
  -- <leader>ft: todo comments, see provide_picker and ak.config.editor.mini_hipatterns.lua
  map("<leader>fu", builtin.resume, { desc = "Resume picker" })
  -- In visual mode: Yank some text, :Pick grep and put(ctrl-r ")
  map("<leader>fw", function() builtin.grep({ pattern = vim.fn.expand("<cword>") }) end, { desc = "Word" })
  local grep_cword_cwd = function()
    builtin.grep({ pattern = vim.fn.expand("<cword>") }, { source = { cwd = H.bdir() } })
  end
  map("<leader>fW", grep_cword_cwd, { desc = "Word (rel)" })
  map("<leader>fx", function()
    vim.cmd.cclose() -- In quickfix, "bql" hides the picker
    extra.list({ scope = "quickfix" })
  end, { desc = "Quickfix" })
  map("<leader>fX", function() extra.list({ scope = "location" }) end, { desc = "Loclist" })

  -- fuzzy other
  map("<leader>fo:", extra.commands, { desc = "Commands" })
  -- <leader>foc: colors, see provide_picker and ak.deps.colors.lua
  map("<leader>foC", function() extra.list({ scope = "change" }) end, { desc = "Changes" })
  map("<leader>fof", builtin.files, { desc = "Files rg" })
  map("<leader>foj", function() extra.list({ scope = "jump" }) end, { desc = "Jumps" })
  map("<leader>foh", extra.hl_groups, { desc = "Highlights" })
  map("<leader>fom", extra.marks, { desc = "Marks" })
  map("<leader>foo", extra.options, { desc = "Options" })
  map("<leader>for", extra.registers, { desc = "Registers" })
  map("<leader>fot", extra.treesitter, { desc = "Treesitter" })
end

local function setup()
  Pick.setup({
    -- Default false, more speed and memory on repeated prompts:
    -- options = { use_cache = false },
  })

  H.setup_autocommands()
  Extra.pickers_enable_label_in_options() -- also uses MiniPickStart event

  keys()
  provide_picker()
  -- vim.ui.select = Pick.ui_select
  vim.ui.select = Extra.pickers.labeled_ui_select
end

setup()
