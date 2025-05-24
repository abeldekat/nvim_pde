---@diagnostic disable: duplicate-set-field
-- - If query starts with `'`, the match is exact.
-- - If query starts with `^`, the match is exact at start.
-- - If query ends with `$`, the match is exact at end.
-- - If query starts with `*`, the match is forced to be fuzzy.
-- - Otherwise match is fuzzy.
-- - Sorting is done to first minimize match width and then match start.
--   Nothing more: no favoring certain places in string, etc.
local Utils = require("ak.util")
local H = {} -- Helper functions

local function setup()
  vim.ui.select = function(items, opts, on_choice)
    local start_opts = { hinted = { enable = true, use_autosubmit = true } }
    return MiniPick.ui_select(items, opts, on_choice, start_opts)
  end
  H.create_autocommands()

  local preview = function(buf_id, item) return MiniPick.default_preview(buf_id, item, { line_position = "center" }) end
  require("mini.pick").setup({ source = { preview = preview } })

  H.to_provide()
  H.add_keys()
  require("ak.mini.pick_hinted").setup({ -- 19 letters, no "bcgpqyz"
    hinted = {
      -- virt_clues_pos = { "inline", "eol" },
      chars = vim.split("adefhijklmnorstuvwx", ""),
    },
  })
end

H.to_provide = function() -- interface to picker to be used in other modules
  local e = MiniExtra.pickers

  ---@type Picker
  local Picker = {
    keymaps = e.keymaps,

    -- Issue # 979 Jump using ctrl-o not correct after navigating with lsp picker(solved)
    -- Or, via the quickfix:
    -- lsp_references = function() vim.lsp.buf.references(nil, { reuse_win = true }) end,
    -- lsp_implementations = function() vim.lsp.buf.implementation({ reuse_win = true }) end,
    -- lsp_type_definitions = function() vim.lsp.buf.type_definition({ reuse_win = true }) end,

    lsp_definitions = function() -- mini.pick: no direct jump to definition(#978):
      -- https://github.com/echasnovski/mini.nvim/issues/979
      -- NOTE: Overridden for lua_ls, unique definition...
      vim.lsp.buf.definition({ scope = "definition" })
    end,
    lsp_references = function() e.lsp({ scope = "references" }) end,
    lsp_implementations = function() e.lsp({ scope = "implementation" }) end,
    lsp_type_definitions = function() e.lsp({ scope = "type_definition" }) end,
    colors = function() e.colorschemes({ names = H.colors_to_use() }, {}) end,
    todo_comments = H.custom.todo_comments,
  }
  Utils.pick.use_picker(Picker)
end

local cwd_cache = {}
H.add_keys = function()
  local b, e = MiniPick.builtin, MiniExtra.pickers

  -- Hotkeys:
  H.mapl("<leader>", H.files, { desc = "Files pick" })
  H.mapl("/", H.custom.buffer_lines_current, { desc = "Buffer lines" })
  H.mapl(";", H.custom.buffers_hinted, { desc = "Buffers pick" }) -- home row, used often
  -- j and <leader>ol: pick_visits_by_labels , see ak.mini.visits_harpooned
  H.mapl("b", H.custom.symbols_hinted, { desc = "Buffer symbols" })
  H.mapl("l", b.grep_live, { desc = "Live grep" })
  H.mapl("r", H.custom.oldfiles_hinted, { desc = "Recent (rel)" })

  -- Fuzzy main. Free: fe,fi,fn,fq,fv,fy
  H.mapl("f/", function() e.history({ scope = "/" }) end, { desc = "'/' history" })
  H.mapl("f:", H.custom.his_cmd_hinted, { desc = "':' history" })
  H.mapl("fa", function() e.git_hunks({ scope = "staged" }) end, { desc = "Staged hunks" })
  local local_opts_staged = { path = vim.fn.expand("%"), scope = "staged" }
  H.mapl("fA", function() e.git_hunks(local_opts_staged) end, { desc = "Staged hunks (current)" })
  H.mapl("fb", b.buffers, { desc = "Buffer pick" })
  H.mapl("fc", e.git_commits, { desc = "Git commits" })
  H.mapl("fC", function() e.git_commits({ path = vim.fn.expand("%") }) end, { desc = "Git commits buffer" })
  H.mapl("fd", function() e.diagnostic({ scope = "current" }) end, { desc = "Diagnostic buffer" })
  H.mapl("fD", function() e.diagnostic({ scope = "all" }) end, { desc = "Diagnostic workspace" })
  H.mapl("ff", H.files, { desc = "Files" })
  H.mapl("fF", function() b.files(nil, { source = { cwd = H.bdir() } }) end, { desc = "Files (rel)" })
  H.mapl("fg", b.grep_live, { desc = "Grep" })
  H.mapl("fG", function() b.grep_live(nil, { source = { cwd = H.bdir() } }) end, { desc = "Grep (rel)" })
  H.mapl("fh", b.help, { desc = "Help" })
  H.mapl("fj", function() e.list({ scope = "jump" }) end, { desc = "Jumps" })
  H.mapl("fk", e.keymaps, { desc = "Key maps" })
  H.mapl("fl", e.buf_lines, { desc = "Buffers lines" })
  H.mapl("fL", function() e.buf_lines({ scope = "current" }) end, { desc = "Buffer lines" })
  H.mapl("fm", e.git_hunks, { desc = "Unstaged hunks" })
  H.mapl("fM", function() e.git_hunks({ path = vim.fn.expand("%") }) end, { desc = "Unstaged hunks (current)" })
  H.mapl("fp", e.hipatterns, { desc = "Hipatterns" })
  H.mapl("fr", e.oldfiles, { desc = "Recent" })
  H.mapl("fR", function() e.oldfiles({ current_dir = true }) end, { desc = "Recent (rel)" })
  H.mapl("fs", function() e.lsp({ scope = "document_symbol" }) end, { desc = "Symbols buffer" })
  H.mapl("fS", function() e.lsp({ scope = "workspace_symbol" }) end, { desc = "Symbols workspace" })
  -- ft: todo comments, see provide_picker and ak.config.editor.mini_hipatterns.lua
  H.mapl("fu", b.resume, { desc = "Resume picker" })
  -- Tip: In visual mode: Yank some text, :Pick grep and put(ctrl-r ")
  local local_opt_cword = { pattern = vim.fn.expand("<cword>") }
  H.mapl("fw", function() b.grep(local_opt_cword) end, { desc = "Word" })
  H.mapl("fW", function() b.grep(local_opt_cword, { source = { cwd = H.bdir() } }) end, { desc = "Word (rel)" })
  H.mapl("fx", function()
    vim.cmd.cclose() -- In quickfix, "bql" hides the picker
    e.list({ scope = "quickfix" })
  end, { desc = "Quickfix" })
  H.mapl("fX", function() e.list({ scope = "location" }) end, { desc = "Loclist" })

  -- Fuzzy other
  H.mapl("fo:", e.commands, { desc = "Commands" })
  -- foc: colors, see provide_picker and ak.deps.colors.lua
  H.mapl("foC", function() e.list({ scope = "change" }) end, { desc = "Changes" })
  H.mapl("fof", b.files, { desc = "Files rg" })
  H.mapl("foh", e.hl_groups, { desc = "Highlights" })
  H.mapl("fom", e.marks, { desc = "Marks" })
  H.mapl("foo", e.options, { desc = "Options" })
  H.mapl("for", e.registers, { desc = "Registers" })
  H.mapl("fot", e.treesitter, { desc = "Treesitter" })
end

-- Helper data ================================================================

H.ns_id = { ak = vim.api.nvim_create_namespace("MiniPickAk") }
H.custom = {} -- all pickers in custom meaningfully modify the opts for MiniPick.start

---@type table<string,function>  event MiniPickStart
H.start_hooks = {}

-- Custom pickers  ================================================================

-- https://github.com/echasnovski/mini.nvim/discussions/518#discussioncomment-7373556
-- Implements: For TODOs in a project, use builtin.grep.
-- Note: hints are possible, but prevent preview on other items
H.custom.todo_comments = function(patterns) --hipatterns.config.highlighters
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

-- https://github.com/echasnovski/mini.nvim/discussions/988
-- Fuzzy search the current buffer with syntax highlighting
-- Last attempt: linenr as extmarks, but no MiniPickMatchRanges highlighting
H.custom.buffer_lines_current = function()
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

local buffer_hints = vim.split("abcdefg", "")
H.custom.buffers_hinted = function() -- Perhaps: Add modified buffers visualization, issue 1810
  local hinted = { enable = true, use_autosubmit = true, chars = buffer_hints }
  MiniPick.builtin.buffers({ include_current = false }, { hinted = hinted })
end

H.custom.symbols_hinted = function()
  MiniExtra.pickers.lsp({ scope = "document_symbol" }, { hinted = { enable = true, use_autosubmit = true } })
end

H.custom.oldfiles_hinted = function() MiniExtra.pickers.oldfiles({ current_dir = true }, { hinted = { enable = true } }) end

H.custom.his_cmd_hinted = function() MiniExtra.pickers.history({ scope = ":" }, { hinted = { enable = true } }) end

H.files = function() -- either files or git_files
  local builtin = MiniPick.builtin
  local cwd = vim.uv.cwd()
  if cwd and cwd_cache[cwd] == nil then cwd_cache[cwd] = vim.uv.fs_stat(".git") and true or false end

  local opts = {}
  if cwd_cache[cwd] then opts.tool = "git" end
  builtin.files(opts)
end

-- Copied
H.show_with_icons = function(buf_id, items, query) MiniPick.default_show(buf_id, items, query, { show_icons = true }) end

H.colors_to_use = function()
  -- stylua: ignore
  local builtins = { -- source code telescope.nvim ignore_builtins
      "blue", "darkblue", "default", "delek", "desert", "elflord", "evening",
      "habamax", "industry", "koehler", "lunaperche", "morning", "murphy",
      "pablo", "peachpuff", "quiet", "retrobox", "ron", "shine", "slate",
      "sorbet", "torte", "vim", "wildcharm", "zaibatsu", "zellner",
  }

  return vim.tbl_filter(
    function(color) return not vim.tbl_contains(builtins, color) end,
    vim.fn.getcompletion("", "color")
  )
end

H.create_autocommands = function()
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
end

H.bdir = function() -- can return nil
  if vim["bo"].buftype == "" then return vim.fn.expand("%:p:h") end
end

H.mapl = function(l, r, opts, mode)
  mode = mode or "n"
  opts["silent"] = opts.silent ~= false
  vim.keymap.set(mode, "<leader>" .. l, r, opts)
end

-- Apply  ================================================================
setup()
