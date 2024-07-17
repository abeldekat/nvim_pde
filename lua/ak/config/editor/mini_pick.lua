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

local M = {}
local Utils = require("ak.util")
local Pick = require("mini.pick")

local H = {} -- Helper functions for custom pickers

---@type table<string,function>  event MiniPickStart
H.start_hooks = {}
---@type table<string,function> event MiniPickStop
H.stop_hooks = {}

H.setup_autocommands = function()
  local group = vim.api.nvim_create_augroup("minipick-hooks", { clear = true })
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

-- https://github.com/echasnovski/mini.nvim/discussions/518#discussioncomment-7373556
-- Implements: For TODOs in a project, use builtin.grep.
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

-- Previewing multiple themes:
-- Press tab for preview, and continue with ctrl-n and ctrl-p
-- The above does not work for nvchad base46(implemented as ui-select)
local selected_colorscheme = nil
Pick.registry.colors = function()
  local on_start = function()
    selected_colorscheme = vim.g.colors_name --
  end
  local on_stop = function()
    vim.schedule(function() -- must use schedule, otherwise eyeliner stops displaying
      vim.cmd.colorscheme(selected_colorscheme)
    end)
  end

  local name = "Colors with preview"
  if H.start_hooks[name] == nil then H.start_hooks[name] = on_start end
  if H.stop_hooks[name] == nil then H.stop_hooks[name] = on_stop end
  return MiniPick.start({
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

-- -- https://github.com/echasnovski/mini.nvim/discussions/988
-- -- Fuzzy search the current buffer with syntax highlighting
-- -- First attempt.
-- Pick.registry.buffer_lines_current = function()
--   local show = function(buf_id, items, query, opts)
--     local buf_target = buf_id
--     if items and #items > 0 then
--       local ft = vim.bo[items[1].bufnr].filetype
--       local has_lang, lang = pcall(vim.treesitter.language.get_lang, ft)
--       local has_ts, _ = pcall(vim.treesitter.start, buf_target, has_lang and lang or ft)
--       if not has_ts and ft then vim.bo[buf_target].syntax = ft end
--     end
--     Pick.default_show(buf_target, items, query, opts)
--   end
--   MiniExtra.pickers.buf_lines({ scope = "current" }, { source = { show = show } })
-- end

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

local function bdir() -- note: in oil dir, return nil and fallback to root cwd
  if vim["bo"].buftype == "" then return vim.fn.expand("%:p:h") end
end

local function map(l, r, opts, mode)
  mode = mode or "n"
  opts["silent"] = opts.silent ~= false
  vim.keymap.set(mode, l, r, opts)
end

local cwd_cache = {}
local function files() -- either files or git_files
  local builtin = Pick.builtin
  local cwd = vim.uv.cwd()
  if cwd and cwd_cache[cwd] == nil then cwd_cache[cwd] = vim.uv.fs_stat(".git") and true or false end

  local opts = {}
  if cwd_cache[cwd] then opts.tool = "git" end
  builtin.files(opts)
end

local function keys()
  local builtin = Pick.builtin
  local extra = MiniExtra.pickers
  local registry = Pick.registry

  -- hotkeys:
  map("<leader><leader>", files, { desc = "Files pick" })
  map("<leader>/", registry.buffer_lines_current, { desc = "Buffer lines" })
  map("<leader>'", builtin.buffers, { desc = "Buffers pick" }) -- home row, used often
  map("<leader>b", function() extra.lsp({ scope = "document_symbol" }) end, { desc = "Buffer symbols" })
  map("<leader>l", builtin.grep_live, { desc = "Live grep" })
  map("<leader>r", function() extra.oldfiles({ current_dir = true }) end, { desc = "Recent (rel)" })

  -- fuzzy main. Free: fe,fj,fn,fq,fv,fy
  map("<leader>f/", function() extra.history({ scope = "/" }) end, { desc = "'/' history" })
  map("<leader>f:", function() extra.history({ scope = ":" }) end, { desc = "':' history" })
  map("<leader>fa", function() extra.git_hunks({ scope = "staged" }) end, { desc = "Staged hunks" })
  map(
    "<leader>fA",
    function() extra.git_hunks({ path = vim.fn.expand("%"), scope = "staged" }) end,
    { desc = "Staged hunks (current)" }
  )
  map("<leader>fb", builtin.buffers, { desc = "Buffer pick" })
  map("<leader>fc", extra.git_commits, { desc = "Git commits" })
  map("<leader>fC", function() extra.git_commits({ path = vim.fn.expand("%") }) end, { desc = "Git commits buffer" })
  map("<leader>fd", function() extra.diagnostic({ scope = "current" }) end, { desc = "Diagnostic buffer" })
  map("<leader>fD", function() extra.diagnostic({ scope = "all" }) end, { desc = "Diagnostic workspace" })
  map("<leader>ff", files, { desc = "Files" })
  map("<leader>fF", function() builtin.files(nil, { source = { cwd = bdir() } }) end, { desc = "Files (rel)" })
  map("<leader>fg", builtin.grep_live, { desc = "Grep" })
  map("<leader>fG", function() builtin.grep_live(nil, { source = { cwd = bdir() } }) end, { desc = "Grep (rel)" })
  map("<leader>fh", builtin.help, { desc = "Help" })
  map("<leader>fi", function() vim.notify("No picker for fzf-lua builtin") end, { desc = "Fzf-lua builtin" })
  map("<leader>fk", extra.keymaps, { desc = "Key maps" })
  map("<leader>fl", registry.buffer_lines_current, { desc = "Buffer lines" })
  map("<leader>fL", function() extra.buf_lines() end, { desc = "Buffers lines" })
  map("<leader>fm", extra.git_hunks, { desc = "Unstaged hunks" })
  map(
    "<leader>fM",
    function() extra.git_hunks({ path = vim.fn.expand("%") }) end,
    { desc = "Unstaged hunks (current)" }
  )
  map("<leader>fp", extra.hipatterns, { desc = "Hipatterns" })
  map("<leader>fr", extra.oldfiles, { desc = "Recent" }) -- could also use fv fV for visits
  map("<leader>fR", function() extra.oldfiles({ current_dir = true }) end, { desc = "Recent (rel)" })
  map("<leader>fs", function() extra.lsp({ scope = "document_symbol" }) end, { desc = "Symbols buffer" })
  map("<leader>fS", function() extra.lsp({ scope = "workspace_symbol" }) end, { desc = "Symbols workspace" })
  -- <leader>ft: todo comments(hipatterns config)
  map("<leader>fu", builtin.resume, { desc = "Resume picker" })
  -- In visual mode: Yank some text, :Pick grep and put(ctrl-r ")
  map("<leader>fw", function() builtin.grep({ pattern = vim.fn.expand("<cword>") }) end, { desc = "Word" })
  map(
    "<leader>fW",
    function() builtin.grep({ pattern = vim.fn.expand("<cword>") }, { source = { cwd = bdir() } }) end,
    { desc = "Word (rel)" }
  )
  map("<leader>fx", function()
    vim.cmd.cclose() -- In quickfix, "bql" hides the picker
    extra.list({ scope = "quickfix" })
  end, { desc = "Quickfix" })
  map("<leader>fX", function() extra.list({ scope = "location" }) end, { desc = "Loclist" })

  -- fuzzy other
  map("<leader>fo:", extra.commands, { desc = "Commands" })
  -- <leader>foc colors( ak.deps colors and ak.config.colors base46)
  map("<leader>foC", function() extra.list({ scope = "change" }) end, { desc = "Changes" })
  map("<leader>fof", builtin.files, { desc = "Files rg" })
  map("<leader>foj", function() extra.list({ scope = "jump" }) end, { desc = "Jumps" })
  map("<leader>foh", extra.hl_groups, { desc = "Highlights" })
  map("<leader>fom", extra.marks, { desc = "Marks" })
  map("<leader>foo", extra.options, { desc = "Options" })
  map("<leader>for", extra.registers, { desc = "Registers" })
  map("<leader>fot", extra.treesitter, { desc = "Treesitter" })
end

local function picker() -- provide the picker to use in other modules
  local extra = MiniExtra.pickers
  local registry = Pick.registry

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

    colors = registry.colors,
    todo_comments = registry.todo_comments,
  }
  Utils.pick.use_picker(Picker)
end

--          ╭─────────────────────────────────────────────────────────╮
--          │                          Setup                          │
--          ╰─────────────────────────────────────────────────────────╯
M.setup = function()
  Pick.setup({
    -- default false, more speed and memory on repeated prompts:
    -- options = { use_cache = false },
    -- window = { config = { border = "solid" } },
  })

  H.setup_autocommands()
  keys()
  picker()
  vim.ui.select = Pick.ui_select
end

return M
