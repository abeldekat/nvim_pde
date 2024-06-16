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

-- NOTE: No picker for autocommands, man-pages and git status

local Utils = require("ak.util")
local Pick = require("mini.pick")

local H = {}
local Path = require("plenary.path")

H.pre_hooks = {}
H.post_hooks = {}

H.setup_autocommands = function()
  local group = vim.api.nvim_create_augroup("minipick-hooks", { clear = true })
  vim.api.nvim_create_autocmd({ "User" }, {
    pattern = "MiniPickStart",
    group = group,
    desc = "Pre hook for picker based on source.name",
    callback = function(...)
      local opts = MiniPick.get_picker_opts() or {}
      local pre_hook = H.pre_hooks[opts.source.name] or function(...) end
      pre_hook(...)
    end,
  })
  vim.api.nvim_create_autocmd({ "User" }, {
    pattern = "MiniPickStop",
    group = group,
    desc = "Post hook for picker based on source.name",
    callback = function(...)
      local opts = MiniPick.get_picker_opts()
      if opts then
        local post_hook = H.post_hooks[opts.source.name] or function(...) end
        post_hook(...)
      else
        vim.notify("MiniPick.get_picker_opts() returned nil")
      end
    end,
  })
end

H.colors = function()
  local skip = Utils.color.builtins_to_skip()
  return vim.tbl_filter(
    function(color) return not vim.tbl_contains(skip, color) end, --
    vim.fn.getcompletion("", "color")
  )
end

-- from telescope oldfiles:
H.buf_in_cwd = function(bufname, cwd)
  if cwd:sub(-1) ~= Path.path.sep then cwd = cwd .. Path.path.sep end
  local bufname_prefix = bufname:sub(1, #cwd)
  return bufname_prefix == cwd
end

-- mini.extra:
H.error = function(msg) error(string.format("(ak.extra) %s", msg), 0) end

-- mini.extra:
H.short_path = function(path, cwd)
  cwd = cwd or vim.fn.getcwd()
  if not vim.startswith(path, cwd) then return vim.fn.fnamemodify(path, ":~") end
  local res = path:sub(cwd:len() + 1):gsub("^/+", ""):gsub("/+$", "")
  return res
end

-- mini.extra:
H.show_with_icons = function(buf_id, items, query) Pick.default_show(buf_id, items, query, { show_icons = true }) end

-- mini.extra:
H.pick_get_config = function() return vim.tbl_deep_extend("force", Pick.config or {}, vim.b.minipick_config or {}) end

-- mini.extra:
H.pick_start = function(items, default_opts, opts)
  local fallback = {
    source = {
      preview = Pick.default_preview,
      choose = Pick.default_choose,
      choose_marked = Pick.default_choose_marked,
    },
  }
  local opts_final = vim.tbl_deep_extend("force", fallback, default_opts, opts or {}, { source = { items = items } })
  return Pick.start(opts_final)
end

--- Copied oldfiles and added option cwd_only
Pick.registry.oldfiles_with_filter = function(local_opts, opts)
  local oldfiles = vim.v.oldfiles
  if not vim.islist(oldfiles) then H.error("`pickers.oldfiles` picker needs valid `v:oldfiles`.") end

  local filter = local_opts and local_opts.cwd_only or false
  local items = vim.schedule_wrap(function()
    local cwd = Pick.get_picker_opts().source.cwd
    local res = {}
    for _, path in ipairs(oldfiles) do
      if vim.fn.filereadable(path) == 1 then
        local use = not filter and true or H.buf_in_cwd(path, cwd) -- added condition
        if use then table.insert(res, H.short_path(path, cwd)) end
      end
    end
    Pick.set_picker_items(res)
  end)

  local show = H.pick_get_config().source.show or H.show_with_icons
  return H.pick_start(items, { source = { name = "Old files cwd", show = show } }, opts)
end

-- https://github.com/echasnovski/mini.nvim/discussions/518#discussioncomment-7373556
-- For TODOs in a project, use builtin.grep.
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
    return pattern:gsub("KEYWORDS", table.concat(keywords, "|"))
  end
  local on_start = function()
    if MiniHipatterns then MiniHipatterns.enable(vim.api.nvim_get_current_buf()) end
  end
  local show = function(buf_id, items, query)
    Pick.default_show(buf_id, change_display(items), query, { show_icons = true }) --
  end

  local name = "Todo-comments"
  if H.pre_hooks[name] == nil then H.pre_hooks[name] = on_start end
  Pick.builtin.grep(
    { tool = "rg", pattern = search_regex(vim.tbl_keys(patterns)) },
    { source = { name = name, show = show } }
  )
end

-- Previewing multiple themes:
-- Press tab for preview, and continue with ctrl-n and ctrl-p
Pick.registry.colors = function()
  local selected_colorscheme = nil
  local on_start = function() selected_colorscheme = vim.g.colors_name end
  local on_stop = function() vim.cmd.colorscheme(selected_colorscheme) end
  local name = "Colors with preview"
  if H.pre_hooks[name] == nil then H.pre_hooks[name] = on_start end
  if H.post_hooks[name] == nil then H.post_hooks[name] = on_stop end
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

local function no_picker(msg) vim.notify("No picker for " .. msg) end

local function bdir() -- note: in oil dir, fallback to root cwd
  if vim["bo"].buftype == "" then return vim.fn.expand("%:p:h") end
end

local function map(l, r, opts, mode)
  mode = mode or "n"
  opts["silent"] = opts.silent ~= false
  vim.keymap.set(mode, l, r, opts)
end

local function keys()
  local builtin = Pick.builtin
  local extra = MiniExtra.pickers
  local registry = Pick.registry

  -- hotkeys:
  map("<leader>/", function() extra.buf_lines({ scope = "current" }) end, { desc = "Buffer fuzzy" })
  map("<leader>o", builtin.buffers, { desc = "Buffers" }) -- mnemonic: open buffers
  map("<leader>e", function() builtin.grep_live() end, { desc = "Grep" })
  map("<leader>r", function() registry.oldfiles_with_filter({ cwd_only = true }) end, { desc = "Recent (rel)" })
  map("<leader>:", function() extra.history({ scope = ":" }) end, { desc = "Command history" })
  map("<leader><leader>", function() builtin.files({ tool = "git" }) end, { desc = "Git files" })

  -- find:
  map("<leader>fb", builtin.buffers, { desc = "Buffers" })
  map("<leader>fg", function() builtin.files({ tool = "git" }) end, { desc = "Git files" })
  map("<leader>ff", builtin.files, { desc = "Find files" })
  map("<leader>fF", function() builtin.files(nil, { source = { cwd = bdir() } }) end, { desc = "Find files (rel)" })
  map("<leader>fr", extra.oldfiles, { desc = "Recent" })
  map("<leader>fR", function() registry.oldfiles_with_filter({ cwd_only = true }) end, { desc = "Recent (rel)" })

  -- git:
  map("<leader>gb", function() extra.git_commits({ path = vim.fn.expand("%") }) end, { desc = "Git commits buffer" })
  map("<leader>gc", extra.git_commits, { desc = "Git commits" })
  map("<leader>gs", extra.git_hunks, { desc = "Modified hunks" }) -- Instead of git status
  map(
    "<leader>gS",
    function() extra.git_hunks({ path = vim.fn.expand("%") }) end,
    { desc = "Modified hunks (current)" }
  )

  -- search
  map('<leader>s"', extra.registers, { desc = "Registers" })
  map("<leader>sa", function() no_picker("Auto commands") end, { desc = "NP: Auto commands" })
  map("<leader>sb", function() extra.buf_lines({ scope = "current" }) end, { desc = "Buffer fuzzy" })
  map("<leader>sc", function() extra.history({ scope = ":" }) end, { desc = "Command history" })
  map("<leader>sC", extra.commands, { desc = "Commands" })
  map("<leader>se", extra.treesitter, { desc = "Treesitter" })
  map("<leader>si", function() no_picker("Picker builtin") end, { desc = "NP: Picker builtin" })
  map("<leader>sg", builtin.grep_live, { desc = "Grep" })
  map("<leader>sG", function() builtin.grep_live(nil, { source = { cwd = bdir() } }) end, { desc = "Grep (rel)" })
  map("<leader>sh", builtin.help, { desc = "Help pages" })
  map("<leader>sH", extra.hl_groups, { desc = "Search highlight groups" })
  map("<leader>sj", function() extra.list({ scope = "jump" }) end, { desc = "Jumplist" }) --**
  map("<leader>sk", extra.keymaps, { desc = "Key maps" })
  map("<leader>sM", function() no_picker("Man pages") end, { desc = "NP: Man pages" })
  map("<leader>sm", extra.marks, { desc = "Jump to mark" })
  map("<leader>so", extra.options, { desc = "Options" })
  map("<leader>sR", builtin.resume, { desc = "Resume" })
  map("<leader>sS", function() extra.lsp({ scope = "workspace_symbol" }) end, { desc = "Goto symbol (workspace)" })
  map("<leader>ss", function() extra.lsp({ scope = "document_symbol" }) end, { desc = "Goto symbol" })
  map("<leader>sw", function() builtin.grep({ pattern = vim.fn.expand("<cword>") }) end, { desc = "Word" })
  map(
    "<leader>sW",
    function() builtin.grep({ pattern = vim.fn.expand("<cword>") }, { source = { cwd = bdir() } }) end,
    { desc = "Word (rel)" }
  )
  -- Not needed: Yank some text, :Pick grep and put(ctrl-r ")
  map("<leader>sw", function() no_picker("Selection") end, { desc = "NP: Selection" }, "v")
  map("<leader>sW", function() no_picker("Selection (rel)") end, { desc = "NP: Selection (rel)" }, "v")

  -- diagnostics/quickfix
  map("<leader>xd", function() extra.diagnostic({ scope = "all" }) end, { desc = "Workspace diagnostics" })
  map("<leader>xD", function() extra.diagnostic({ scope = "current" }) end, { desc = "Document diagnostics" })
  map("<leader>xx", function() extra.list({ scope = "quickfix" }) end, { desc = "Quickfix search" })
  map("<leader>xX", function() no_picker("Quickfixhis search") end, { desc = "NP: Quickfixhis search" })
  map("<leader>xz", function() extra.list({ scope = "location" }) end, { desc = "Loclist search" })

  -- only implemented by mini.pick:
  map("<leader>sB", extra.buf_lines, { desc = "Buffers fuzzy" })
  map("<leader>sp", extra.hipatterns, { desc = "Buffers hipatterns" })
  map("<leader>ga", function() extra.git_hunks({ scope = "staged" }) end, { desc = "Added hunks" })
  map(
    "<leader>gA",
    function() extra.git_hunks({ path = vim.fn.expand("%"), scope = "staged" }) end,
    { desc = "Added hunks (current)" }
  )
end

local function extensions()
  vim.ui.select = Pick.ui_select
  -- aerial telescope extension: leader ss
  -- telescope alternate: ml
end

local function picker()
  local builtin = Pick.builtin
  local extra = MiniExtra.pickers
  local registry = Pick.registry

  ---@type Picker
  local Picker = {
    find_files = builtin.files,
    live_grep = builtin.grep_live,
    keymaps = extra.keymaps,
    oldfiles = extra.oldfiles,
    lsp_definitions = function() extra.lsp({ scope = "definition" }) end,
    lsp_references = function() extra.lsp({ scope = "references" }) end,
    lsp_implementations = function() extra.lsp({ scope = "implementation" }) end,
    lsp_type_definitions = function() extra.lsp({ scope = "type_definition" }) end,
    colors = registry.colors,
    todo_comments = registry.todo_comments,
  }
  Utils.pick.use_picker(Picker)
end

local function get_opts()
  return {
    -- default false, more speed and memory on repeated prompts:
    -- options = { use_cache = false },
  }
end

--          ╭─────────────────────────────────────────────────────────╮
--          │                          Setup                          │
--          ╰─────────────────────────────────────────────────────────╯
local function setup()
  Pick.setup(get_opts())
  H.setup_autocommands()
  keys()
  extensions()
  picker()
end
setup()
