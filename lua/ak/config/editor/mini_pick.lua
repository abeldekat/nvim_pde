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

-- Extra: Implements feature adding labels to pickers  ======================================================

-- Take opts.label into account and override opts.source.{match, show}
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

  -- -- test ui_select for labeled pickers
  -- local on_choice = function(choice)
  --   if not choice then return end
  --   vim.notify(choice)
  -- end
  -- local select_hello = function() vim.ui.select({ "Hello", "Helloooo", "Helloooooo" }, { prompt = "Say hi" }, on_choice) end
  -- map("<leader>fy", select_hello, { desc = "Labeled ui select", silent = true })

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
  Pick.setup({})

  H.setup_autocommands()
  Extra.pickers_enable_label_in_options() -- also uses MiniPickStart event
  vim.ui.select = Extra.pickers.labeled_ui_select -- Pick.ui_select

  keys()
  provide_picker()
end

setup()
