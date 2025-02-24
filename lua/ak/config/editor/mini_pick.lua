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
local H = {} -- Helper functions

local function setup()
  ---@diagnostic disable-next-line: duplicate-set-field
  vim.ui.select = function(items, opts, on_choice)
    local start_opts = { hinted = { enable = true, use_autosubmit = true } }
    return MiniPick.ui_select(items, opts, on_choice, start_opts)
  end

  require("mini.pick").setup({})

  H.setup_autocommands()
  H.add_custom_pickers()
  H.provide_picker()
  H.add_keys()

  require("ak.mini.pick_hinted").setup({ -- 19 letters, no "bcgpqyz"
    hinted = {
      -- virt_clues_pos = { "inline", "eol" },
      chars = vim.split("adefhijklmnorstuvwx", ""),
    },
  })
end

H.setup_autocommands = function()
  local group = vim.api.nvim_create_augroup("minipick-custom-hooks", { clear = true })
  local function au(pattern, desc, hooks)
    vim.api.nvim_create_autocmd({ "User" }, {
      pattern = pattern,
      group = group,
      desc = desc,
      callback = function(...)
        local opts = MiniPick.get_picker_opts() or {}
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

H.add_custom_pickers = function()
  MiniPick.registry.todo_comments = H.todo_comments
  MiniPick.registry.colors_with_preview = H.colors_with_preview
  MiniPick.registry.buffer_lines_current = H.buffer_lines_current
  MiniPick.registry.buffers_hinted_truncated = H.buffer_lines_current
end

H.provide_picker = function() -- interface to picker to be used in other modules
  local extra = MiniExtra.pickers
  local custom = MiniPick.registry

  ---@type Picker
  local Picker = {
    keymaps = extra.keymaps,

    -- mini.pick: no direct jump to definition(#978):
    lsp_definitions = function() vim.lsp.buf.definition({ reuse_win = true }) end,

    lsp_references = function() extra.lsp({ scope = "references" }) end,
    lsp_implementations = function() extra.lsp({ scope = "implementation" }) end,
    lsp_type_definitions = function() extra.lsp({ scope = "type_definition" }) end,
    -- Or, via the quickfix:
    -- lsp_references = function() vim.lsp.buf.references(nil, { reuse_win = true }) end,
    -- lsp_implementations = function() vim.lsp.buf.implementation({ reuse_win = true }) end,
    -- lsp_type_definitions = function() vim.lsp.buf.type_definition({ reuse_win = true }) end,

    colors = custom.colors_with_preview,
    todo_comments = custom.todo_comments,
  }
  Utils.pick.use_picker(Picker)
end

local cwd_cache = {}
H.add_keys = function()
  local function files() -- either files or git_files
    local builtin = MiniPick.builtin
    local cwd = vim.uv.cwd()
    if cwd and cwd_cache[cwd] == nil then cwd_cache[cwd] = vim.uv.fs_stat(".git") and true or false end

    local opts = {}
    if cwd_cache[cwd] then opts.tool = "git" end
    builtin.files(opts)
  end
  local function map(l, r, opts, mode)
    mode = mode or "n"
    opts["silent"] = opts.silent ~= false
    vim.keymap.set(mode, l, r, opts)
  end
  local builtin = MiniPick.builtin
  local extra = MiniExtra.pickers
  local custom = MiniPick.registry

  -- hotkeys:
  map("<leader><leader>", files, { desc = "Files pick" })
  map("<leader>/", custom.buffer_lines_current, { desc = "Buffer lines" })
  map("<leader>;", custom.buffers_hinted_truncated, { desc = "Buffers pick" }) -- home row, used often
  -- <leader>j and <leader>ol: pick_visits_by_labels , see ak.mini.visits_harpooned
  local symbols_hinted = function()
    extra.lsp({ scope = "document_symbol" }, { hinted = { enable = true, use_autosubmit = true } })
  end
  map("<leader>b", symbols_hinted, { desc = "Buffer symbols" })
  map("<leader>l", builtin.grep_live, { desc = "Live grep" })
  local oldfiles_hinted = function() extra.oldfiles({ current_dir = true }, { hinted = { enable = true } }) end
  map("<leader>r", oldfiles_hinted, { desc = "Recent (rel)" })

  -- fuzzy main. Free: fe,fn,fq,fv,fy
  map("<leader>f/", function() extra.history({ scope = "/" }) end, { desc = "'/' history" })
  local his_cmd_hinted = function() extra.history({ scope = ":" }, { hinted = { enable = true } }) end
  map("<leader>f:", his_cmd_hinted, { desc = "':' history" })
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
  map("<leader>fj", function() extra.list({ scope = "jump" }) end, { desc = "Jumps" })
  map("<leader>fk", extra.keymaps, { desc = "Key maps" })
  map("<leader>fl", extra.buf_lines, { desc = "Buffers lines" })
  map("<leader>fL", function() extra.buf_lines({ scope = "current" }) end, { desc = "Buffer lines" })
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
  map("<leader>foh", extra.hl_groups, { desc = "Highlights" })
  map("<leader>fom", extra.marks, { desc = "Marks" })
  map("<leader>foo", extra.options, { desc = "Options" })
  map("<leader>for", extra.registers, { desc = "Registers" })
  map("<leader>fot", extra.treesitter, { desc = "Treesitter" })
end

-- Helper data ================================================================

H.ns_id = { ak = vim.api.nvim_create_namespace("MiniPickAk") }

-- Copied
H.show_with_icons = function(buf_id, items, query) MiniPick.default_show(buf_id, items, query, { show_icons = true }) end
---@type table<string,function>  event MiniPickStart
H.start_hooks = {}
---@type table<string,function> event MiniPickStop
H.stop_hooks = {}

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

H.bdir = function() -- can return nil
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

-- Custom pickers  ================================================================

-- https://github.com/echasnovski/mini.nvim/discussions/518#discussioncomment-7373556
-- Implements: For TODOs in a project, use builtin.grep.
-- Note: hints are possible, but prevent preview on other items
H.todo_comments = function(patterns) --hipatterns.config.highlighters
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
    MiniPick.default_show(buf_id, change_display(items), query, { show_icons = true }) --
  end

  local name = "Todo-comments"
  if H.start_hooks[name] == nil then H.start_hooks[name] = on_start end
  MiniPick.builtin.grep(
    { tool = "rg", pattern = search_regex(vim.tbl_keys(patterns)) },
    { source = { name = name, show = show } }
  )
end

-- https://github.com/echasnovski/mini.nvim/discussions/951
-- Previewing multiple themes:
-- Press tab for preview, and continue with ctrl-n and ctrl-p
-- Note: hints are possible, but most relevant items are not on top
local selected_colorscheme = nil
H.colors_with_preview = function()
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
    hinted = { enable = true },
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
H.buffer_lines_current = function()
  local show = function(buf_id, items, query, opts)
    if items == nil or #items == 0 then return end

    -- Show as usual
    MiniPick.default_show(buf_id, items, query, opts)

    -- Move prefix line numbers into inline extmarks
    local lines = vim.api.nvim_buf_get_lines(buf_id, 0, -1, false)
    local digit_prefixes = {}
    for i, l in ipairs(lines) do
      local _, prefix_end, prefix = l:find("^(%s*%d+│)")
      if prefix_end ~= nil then
        digit_prefixes[i], lines[i] = prefix, l:sub(prefix_end + 1)
      end
    end

    vim.api.nvim_buf_set_lines(buf_id, 0, -1, false, lines)
    for i, pref in pairs(digit_prefixes) do
      local extmark_opts = { virt_text = { { pref, "MiniPickNormal" } }, virt_text_pos = "inline" }
      vim.api.nvim_buf_set_extmark(buf_id, H.ns_id.ak, i - 1, 0, extmark_opts)
    end

    -- Set highlighting based on the curent filetype
    local ft = vim.bo[items[1].bufnr].filetype
    local has_lang, lang = pcall(vim.treesitter.language.get_lang, ft)
    local has_ts, _ = pcall(vim.treesitter.start, buf_id, has_lang and lang or ft)
    if not has_ts and ft then vim.bo[buf_id].syntax = ft end
  end
  -- local local_opts = { scope = "current", preserve_order = true }
  local local_opts = { scope = "current" }
  MiniExtra.pickers.buf_lines(local_opts, { source = { show = show } })
end

-- Buffers show name in cwd format: https://github.com/echasnovski/mini.nvim/issues/1290
-- Show buffers: If in cwd, show in cwd format
-- Code taken from builtin.buffers
--
-- Default pick buffers just shows parsed output from buffers command
-- As a consequence, the cwd part is not removed from buffers opened from dashboard
H.buffers_hinted_truncated = function()
  local cwd = vim.fn.fnamemodify(vim.fs.normalize(vim.fn.getcwd()) .. "/", ":~")
  local include_unlisted = false
  local include_current = false

  local items = {}
  local cur_buf_id = vim.api.nvim_get_current_buf()
  local buffers_output = vim.api.nvim_exec2("buffers" .. (include_unlisted and "!" or ""), { output = true })
  ---@diagnostic disable-next-line: undefined-field
  local buffers_string = buffers_output.output and buffers_output.output or ""

  if buffers_string ~= "" then
    for _, l in ipairs(vim.split(buffers_string, "\n")) do
      local buf_id_str, buf_name = l:match("^%s*%d+"), l:match('"(.*)"')
      if vim.startswith(buf_name, cwd) then buf_name = vim.fn.fnamemodify(buf_name, ":.") end

      local buf_id = tonumber(buf_id_str)
      local item = { text = buf_name, bufnr = buf_id }
      if buf_id ~= cur_buf_id or include_current then table.insert(items, item) end
    end
  end

  local hinted = { enable = true, use_autosubmit = true, chars = vim.split("abcdefg", "") }
  local source = {
    name = "Buffers hinted truncated",
    items = items,
    show = true and MiniPick.default_show or nil, -- true: icons
    window = false and H.make_centered_window() or nil, -- true: centered_window
  }
  MiniPick.start({ hinted = hinted, source = source })
end

-- Apply  ================================================================
setup()
