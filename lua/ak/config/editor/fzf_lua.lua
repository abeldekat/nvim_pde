--          ╭─────────────────────────────────────────────────────────╮
--          │                  WIP: Testing fzf-lua                   │
--          ╰─────────────────────────────────────────────────────────╯
local Utils = require("ak.util")

local function map(l, r, opts, mode)
  mode = mode or "n"
  opts["silent"] = opts.silent ~= false
  vim.keymap.set(mode, l, r, opts)
end

local function no_picker(msg) vim.notify("No picker for " .. msg) end

local function get_opts() return {} end

local function keys()
  -- hotkeys:
  map("<leader>/", function() no_picker("Search in buffer") end, { desc = "Buffer fuzzy" })
  map("<leader>o", function() no_picker("Other buffers") end, { desc = "Buffers" })
  map("<leader>e", function() no_picker("Grep") end, { desc = "Grep" })
  map("<leader>r", function() no_picker("Recent (rel)") end, { desc = "Recent (rel)" })
  map("<leader>:", function() no_picker("Command history") end, { desc = "Command history" })
  map("<leader><leader>", function() no_picker("Git files") end, { desc = "Git files" })

  -- find:
  map("<leader>fb", function() no_picker("Buffers") end, { desc = "Buffers" })
  map("<leader>fg", function() no_picker("Git files") end, { desc = "Git files" })
  map("<leader>ff", function() no_picker("Find files") end, { desc = "Find files" })
  map("<leader>fF", function() no_picker("Find files (rel)") end, { desc = "Find files (rel)" })
  map("<leader>fr", function() no_picker("Recent") end, { desc = "Recent" })
  map("<leader>fR", function() no_picker("Recent (rel)") end, { desc = "Recent (rel)" })

  -- git
  map("<leader>gb", function() no_picker("bcommits") end, { desc = "Git commits buffer" })
  map("<leader>gc", function() no_picker("commits") end, { desc = "Git commits" })
  map("<leader>gs", function() no_picker("status") end, { desc = "Git status" })

  -- search
  map('<leader>s"', function() no_picker("Registers") end, { desc = "Registers" })
  map("<leader>sa", function() no_picker("Auto commands") end, { desc = "Auto commands" })
  map("<leader>sb", function() no_picker("Buffer fuzzy") end, { desc = "Buffer fuzzy" })
  map("<leader>sc", function() no_picker("Command history") end, { desc = "Command history" })
  map("<leader>sC", function() no_picker("Commands") end, { desc = "Commands" })
  map("<leader>se", function() no_picker("Treesitter") end, { desc = "Treesitter" })
  map("<leader>si", function() no_picker("Picker builtin") end, { desc = "Picker builtin" })
  map("<leader>sg", function() no_picker("Grep") end, { desc = "Grep" })
  map("<leader>sG", function() no_picker("Grep (rel)") end, { desc = "Grep (rel)" })
  map("<leader>sh", function() no_picker("Help pages") end, { desc = "Help pages" })
  map("<leader>sH", function() no_picker("Search highlight groups") end, { desc = "Search highlight groups" })
  map("<leader>sj", function() no_picker("Jumplist") end, { desc = "Jumplist" })
  map("<leader>sk", function() no_picker("Key maps") end, { desc = "Key maps" })
  map("<leader>sM", function() no_picker("Man pages") end, { desc = "Man pages" })
  map("<leader>sm", function() no_picker("Jump to mark") end, { desc = "Jump to mark" })
  map("<leader>so", function() no_picker("Options") end, { desc = "Options" })
  map("<leader>sR", function() no_picker("Resume") end, { desc = "Resume" })
  map("<leader>sS", function() no_picker("Goto symbol (workspace)") end, { desc = "Goto symbol (workspace)" })
  map("<leader>ss", function() no_picker("Goto symbol") end, { desc = "Goto symbol" })
  map("<leader>sw", function() no_picker("Word") end, { desc = "Word" })
  map("<leader>sW", function() no_picker("Word (rel)") end, { desc = "Word (rel)" })
  map("<leader>sw", function() no_picker("Selection") end, { desc = "Selection" }, "v")
  map("<leader>sW", function() no_picker("Selection (rel)") end, { desc = "Selection (rel)" }, "v")

  -- diagnostics/quickfix
  map("<leader>xd", function() no_picker("Workspace diagnostics") end, { desc = "Workspace diagnostics" })
  map("<leader>xD", function() no_picker("Document diagnostics") end, { desc = "Document diagnostics" })
  -- The bqf plugin needs the fzf plugin to search the quickfix. Use picker instead.
  map("<leader>xx", function() no_picker("Quickfix search") end, { desc = "Quickfix search" })
  map("<leader>xX", function() no_picker("Quickfixhis search") end, { desc = "Quickfixhis search" })
  map("<leader>xz", function() no_picker("Loclist search") end, { desc = "Loclist search" })

  -- only implemented by mini.pick:
  map("<leader>sB", function() no_picker("Buffers fuzzy") end, { desc = "Buffers fuzzy" })
  map("<leader>sp", function() no_picker("Buffers hipatterns") end, { desc = "Buffers hipatterns" })
end

local function extensions() end

local function picker()
  ---@type Picker
  local Picker = {
    find_files = function() no_picker("find_files") end,
    live_grep = function() no_picker("live_grep") end,
    keymaps = function() no_picker("keymaps") end,
    oldfiles = function() no_picker("oldfiles") end,
    lsp_definitions = function() no_picker("lsp_definitions") end,
    lsp_references = function() no_picker("lsp_references") end,
    lsp_implementations = function() no_picker("lsp_implementations") end,
    lsp_type_definitions = function() no_picker("lsp_type_definitions") end,
    colors = function() no_picker("colors") end,
    todo_comments = function() no_picker("todo_comments") end,
  }
  Utils.pick.use_picker(Picker)
end

--          ╭─────────────────────────────────────────────────────────╮
--          │                          Setup                          │
--          ╰─────────────────────────────────────────────────────────╯
local function setup()
  require("fzf-lua").setup(get_opts())
  keys()
  extensions()
  picker()
end
setup()
