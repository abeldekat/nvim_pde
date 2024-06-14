--          ╭─────────────────────────────────────────────────────────╮
--          │                 WIP: Testing mini.pick                  │
--          ╰─────────────────────────────────────────────────────────╯

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

local Utils = require("ak.util")

local function bdir()
  -- note: in oil dir, fallback to root cwd
  if vim["bo"].buftype == "" then return vim.fn.expand("%:p:h") end
end

local function color_picker()
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

local function no_picker(msg) vim.notify("No picker for " .. msg) end

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
  local builtin = MiniPick.builtin
  local extra = MiniExtra.pickers

  -- hotkeys:
  map("<leader>/", function() extra.buf_lines({ scope = "current" }) end, { desc = "Buffer fuzzy" })
  map("<leader>o", function() builtin.buffers() end, { desc = "Buffers" }) -- mnemonic: open buffers
  map("<leader>e", function() builtin.grep_live() end, { desc = "Grep" })
  map("<leader>r", function() extra.oldfiles() end, { desc = "Recent" })
  map("<leader>:", function() extra.history({ scope = ":" }) end, { desc = "Command history" })
  map("<leader><leader>", function() builtin.files({ tool = "git" }) end, { desc = "Git files" })

  -- find:
  map("<leader>fb", function() builtin.buffers() end, { desc = "Buffers" })
  map("<leader>fg", function() builtin.files({ tool = "git" }) end, { desc = "Git files" })
  map("<leader>ff", function() builtin.files() end, { desc = "Find files" })
  map("<leader>fF", function() builtin.files(nil, { source = { cwd = bdir() } }) end, { desc = "Find files (rel)" })
  map("<leader>fr", function() extra.oldfiles() end, { desc = "Recent" })
  map("<leader>fR", function() no_picker("Recent (rel)") end, { desc = "NP: Recent (rel)" })

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
  vim.ui.select = MiniPick.ui_select
  -- aerial telescope extension: leader ss
  -- telescope alternate: ml
end

-- TODO:
-- Ask: Lsp always shows the picker even if there is only one.
-- Ask: Quickfixhis search
-- Ask: Oldfiles does not take cwd into account: extra.oldfiles({}, { source = { cwd = bdir() } })
-- Use treesitter picker
-- Test hipatterns
-- Decide: Git status versus git hunks staged/unstaged
-- Perhaps: search all buf_lines: Default = all buffers
-- Test extra.list scope = "change"
local function picker()
  local builtin = MiniPick.builtin
  local extra = MiniExtra.pickers

  ---@type Picker
  local Picker = {
    find_files = function() builtin.files() end,
    live_grep = function() builtin.grep_live() end,
    keymaps = function() extra.keymaps() end,
    oldfiles = function() extra.oldfiles() end,
    lsp_definitions = function() extra.lsp({ scope = "definition" }) end,
    lsp_references = function() extra.lsp({ scope = "references" }) end,
    lsp_implementations = function() extra.lsp({ scope = "implementation" }) end,
    lsp_type_definitions = function() extra.lsp({ scope = "type_definition" }) end,
    colors = function() color_picker() end,
  }
  Utils.pick.use_picker(Picker)
end

--          ╭─────────────────────────────────────────────────────────╮
--          │                          Setup                          │
--          ╰─────────────────────────────────────────────────────────╯
local function setup()
  require("mini.pick").setup(get_opts())
  keys()
  extensions()
  picker()
end
setup()
