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

-- TODO: search all buf_lines: Default = all buffers. Useful in workflow?
-- TODO: Use treesitter picker and hipatterns(only in open buffers)

local Utils = require("ak.util")
local Pick = require("mini.pick")

local function no_picker(msg) vim.notify("No picker for " .. msg) end

local H = {} -- Helpers copied from mini.extra
local ExtraAK = { pickers = {} }
local Path = require("plenary.path")

-- from telescope oldfiles:
---@return boolean
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

--- Added option cwd_only:
--- Old files picker.
---
--- Pick from |v:oldfiles| entries representing readable files.
---
---@param local_opts __extra_pickers_local_opts
---   Not used at the moment.
---@param opts __extra_pickers_opts
---
---@return __extra_pickers_return
ExtraAK.pickers.oldfiles = function(local_opts, opts)
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
-- For TODOs in a project, use builtin.grep
--
-- patterns: see mini.hipatterns, config, highlighters
ExtraAK.pickers.todo_comments = function(patterns)
  local function enable_hipatterns(buf_id)
    if MiniHipatterns then MiniHipatterns.enable(buf_id) end
  end
  local function search_regex(keywords)
    local pattern = [[\b(KEYWORDS):]]
    return pattern:gsub("KEYWORDS", table.concat(keywords, "|"))
  end

  local show = function(buf_id, items, query)
    enable_hipatterns(buf_id)
    Pick.default_show(
      buf_id,
      vim.tbl_map(function(item)
        local s = string.gsub(item, "│", "") -- remove character used by comment box
        s = string.gsub(s, "-- ", " ") -- remove comment before and todo keep one space
        s = string.gsub(s, "%s+", " ") -- change multiple spaces into one space
        return s
      end, items),
      query
    )
  end
  local preview = function(buf_id, item)
    enable_hipatterns(buf_id)
    Pick.default_preview(buf_id, item)
  end

  Pick.builtin.grep(
    { tool = "rg", pattern = search_regex(vim.tbl_keys(patterns)) },
    { source = { name = "Todo-comments", show = show, preview = preview } }
  )
end

ExtraAK.pickers.color_picker = function()
  local target = vim.fn.getcompletion
  local skip = Utils.color.builtins_to_skip()

  ---@diagnostic disable-next-line: duplicate-set-field
  vim.fn.getcompletion = function()
    ---@diagnostic disable-next-line: redundant-parameter
    return vim.tbl_filter(
      function(color) return not vim.tbl_contains(skip, color) end, --
      target("", "color")
    )
  end

  vim.ui.select(vim.fn.getcompletion(), { prompt = "Select colorscheme" }, function(choice)
    if not choice then return end
    vim.cmd.colorscheme(choice)
  end)

  vim.fn.getcompletion = target
end

local function bdir()
  -- note: in oil dir, fallback to root cwd
  if vim["bo"].buftype == "" then return vim.fn.expand("%:p:h") end
end

local function map(l, r, opts, mode)
  mode = mode or "n"
  opts["silent"] = opts.silent ~= false
  vim.keymap.set(mode, l, r, opts)
end

local function get_opts()
  return {
    -- default false, more speed and memory on repeated prompts:
    -- options = { use_cache = false },
  }
end

local function keys()
  local builtin = Pick.builtin
  local extra = MiniExtra.pickers
  local ak_extra = ExtraAK.pickers

  -- hotkeys:
  map("<leader>/", function() extra.buf_lines({ scope = "current" }) end, { desc = "Buffer fuzzy" })
  map("<leader>o", function() builtin.buffers() end, { desc = "Buffers" }) -- mnemonic: open buffers
  map("<leader>e", function() builtin.grep_live() end, { desc = "Grep" })
  map("<leader>r", function() ak_extra.oldfiles({ cwd_only = true }) end, { desc = "Recent (rel)" })
  map("<leader>:", function() extra.history({ scope = ":" }) end, { desc = "Command history" })
  map("<leader><leader>", function() builtin.files({ tool = "git" }) end, { desc = "Git files" })

  -- find:
  map("<leader>fb", function() builtin.buffers() end, { desc = "Buffers" })
  map("<leader>fg", function() builtin.files({ tool = "git" }) end, { desc = "Git files" })
  map("<leader>ff", function() builtin.files() end, { desc = "Find files" })
  map("<leader>fF", function() builtin.files(nil, { source = { cwd = bdir() } }) end, { desc = "Find files (rel)" })
  map("<leader>fr", function() extra.oldfiles() end, { desc = "Recent" })
  map("<leader>fR", function() ak_extra.oldfiles({ cwd_only = true }) end, { desc = "Recent (rel)" })

  -- git:
  map("<leader>gb", function() extra.git_commits({ path = vim.fn.expand("%") }) end, { desc = "Git commits buffer" })
  map("<leader>gc", function() extra.git_commits() end, { desc = "Git commits" })
  map("<leader>gs", function() extra.git_hunks({ scope = "staged" }) end, { desc = "Git status" })

  -- search
  map('<leader>s"', function() extra.registers() end, { desc = "Registers" })
  map("<leader>sa", function() no_picker("Auto commands") end, { desc = "NP: Auto commands" })
  map("<leader>sb", function() extra.buf_lines({ scope = "current" }) end, { desc = "Buffer fuzzy" })
  map("<leader>sc", function() extra.history({ scope = ":" }) end, { desc = "Command history" })
  map("<leader>sC", function() extra.commands() end, { desc = "Commands" })
  map("<leader>si", function() no_picker("Picker builtin") end, { desc = "NP: Picker builtin" })
  map("<leader>sg", function() builtin.grep_live() end, { desc = "Grep" })
  map("<leader>sG", function() builtin.grep_live(nil, { source = { cwd = bdir() } }) end, { desc = "Grep (rel)" })
  map("<leader>sh", function() builtin.help() end, { desc = "Help pages" })
  map("<leader>sH", function() extra.hl_groups() end, { desc = "Search highlight groups" })
  map("<leader>sj", function() extra.list({ scope = "jump" }) end, { desc = "Jumplist" }) --**
  map("<leader>sk", function() extra.keymaps() end, { desc = "Key maps" })
  map("<leader>sM", function() no_picker("Man pages") end, { desc = "NP: Man pages" })
  map("<leader>sm", function() extra.marks() end, { desc = "Jump to mark" })
  map("<leader>so", function() extra.options() end, { desc = "Options" })
  map("<leader>sR", function() builtin.resume() end, { desc = "Resume" })
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
end

local function extensions()
  vim.ui.select = Pick.ui_select
  -- aerial telescope extension: leader ss
  -- telescope alternate: ml
end

-- TODO:
-- Ask: Lsp always shows the picker even if there is only one.
-- Ask: Quickfixhis search
-- Decide: Git status versus git hunks staged/unstaged
local function picker()
  local builtin = Pick.builtin
  local extra = MiniExtra.pickers
  local ak_extra = ExtraAK.pickers

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
    colors = ak_extra.color_picker,
    todo_comments = ak_extra.todo_comments,
  }
  Utils.pick.use_picker(Picker)
end

--          ╭─────────────────────────────────────────────────────────╮
--          │                          Setup                          │
--          ╰─────────────────────────────────────────────────────────╯
local function setup()
  Pick.setup(get_opts())
  keys()
  extensions()
  picker()
end
setup()
