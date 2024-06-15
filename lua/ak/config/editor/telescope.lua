local Utils = require("ak.util")

-- patterns: mini.hipatterns, config, highlighters
local function todo_comments(patterns)
  local function todo_opts()
    local function search_regex(keywords)
      local pattern = [[\b(KEYWORDS):]]
      return pattern:gsub("KEYWORDS", table.concat(keywords, "|"))
    end

    local opts = {}
    -- stylua: ignore start
    opts.vimgrep_arguments = {
      "rg", "--color=never", "--no-heading", "--with-filename", "--line-number", "--column"
    }
    -- stylua: ignore end
    opts.prompt_title = "Find Todo"
    opts.use_regex = true
    opts.search = search_regex(vim.tbl_keys(patterns))
    local entry_maker = require("telescope.make_entry").gen_from_vimgrep(opts)
    opts.entry_maker = function(line)
      local entry_result = entry_maker(line)

      entry_result.display = function(entry)
        local function find_todo()
          for _, hl in pairs(patterns) do
            local pattern = hl.pattern:sub(2) -- remove the prepending space
            if entry.text:find(pattern, 1, true) then return hl end
          end
          return patterns[1] -- prevent nil
        end
        local todo = find_todo()
        local display = string.format("%s:%s:%s ", entry.filename, entry.lnum, entry.col)
        local text_result = todo.pattern .. " " .. display .. " " .. entry.text
        return text_result, { { { 0, #todo.pattern }, todo.group } }
      end
      return entry_result
    end
    return opts
  end

  require("telescope.builtin").grep_string(todo_opts())
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

  vim.cmd("Telescope colorscheme enable_preview=true")
  vim.fn.getcompletion = target
end

local function map(l, r, opts, mode)
  mode = mode or "n"
  opts["silent"] = opts.silent ~= false
  vim.keymap.set(mode, l, r, opts)
end

--          ╭─────────────────────────────────────────────────────────╮
--          │                          Opts                           │
--          ╰─────────────────────────────────────────────────────────╯
local function get_opts()
  local actions = require("telescope.actions")
  local layout_actions = require("telescope.actions.layout")

  local find_files_no_ignore = function()
    local action_state = require("telescope.actions.state")
    local line = action_state.get_current_line()
    require("telescope.builtin").find_files({ no_ignore = true, default_text = line })
  end
  local find_files_with_hidden = function()
    local action_state = require("telescope.actions.state")
    local line = action_state.get_current_line()
    require("telescope.builtin").find_files({ hidden = true, default_text = line })
  end

  local opts = {
    defaults = {
      path_display = { filename_first = { reverse_directories = false } },
      prompt_prefix = " ",
      selection_caret = " ",
      -- open files in the first window that is an actual file.
      -- use the current window if no other window is available.
      get_selection_window = function()
        local wins = vim.api.nvim_list_wins()
        table.insert(wins, 1, vim.api.nvim_get_current_win())
        for _, win in ipairs(wins) do
          local buf = vim.api.nvim_win_get_buf(win)
          if vim.bo[buf].buftype == "" then return win end
        end
        return 0
      end,
      sorting_strategy = "ascending",
      layout_strategy = "flex",
      layout_config = {
        prompt_position = "top",
        -- horizontal = { preview_width = 0.55, },
        flex = {
          flip_columns = 140,
        },
      },
      mappings = {
        i = {
          ["<a-i>"] = find_files_no_ignore,
          ["<a-h>"] = find_files_with_hidden,
          ["<C-Down>"] = actions.cycle_history_next,
          ["<C-Up>"] = actions.cycle_history_prev,
          ["<Down>"] = layout_actions.cycle_layout_prev, -- duplicate move_selection_previous
          ["<Up>"] = layout_actions.cycle_layout_next, -- duplicate move_selection_end

          ["<a-p>"] = layout_actions.toggle_preview,
          ["<a-m>"] = layout_actions.toggle_mirror,
          ["<a-o>"] = layout_actions.toggle_prompt_position,
          ["<C-c>"] = false, -- double escape actions.close,
        },
        n = {
          ["q"] = actions.close,
          ["<Down>"] = false,
          ["<Up>"] = false,
        },
      },
    },
    extensions = {
      ["ui-select"] = {
        require("telescope.themes").get_dropdown(),
      },
    },
  }
  return opts
end

--          ╭─────────────────────────────────────────────────────────╮
--          │                          Keys                           │
--          ╰─────────────────────────────────────────────────────────╯
-- searching: Telescope default is vim.uv.cwd. May also be relative to buffer
local function keys()
  local builtin = require("telescope.builtin")
  local themes = require("telescope.themes")
  local buffer_dir = require("telescope.utils").buffer_dir

  -- hotkeys:
  map(
    "<leader>/",
    function()
      builtin.current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({
        winblend = 10,
        previewer = false,
      }))
    end,
    { desc = "Buffer fuzzy" }
  )
  map("<leader>o", function() builtin.buffers({ sort_mru = true }) end, { desc = "Buffers" })
  map("<leader>e", function() builtin.live_grep(themes.get_ivy({})) end, { desc = "Grep" })
  map("<leader>r", function() builtin.oldfiles({ cwd_only = true }) end, { desc = "Recent (rel)" })
  map("<leader>:", function() builtin.command_history() end, { desc = "Command history" })
  map("<leader><leader>", function() builtin.git_files({ show_untracked = true }) end, { desc = "Git files" })

  -- find:
  map("<leader>fb", function() builtin.buffers({ sort_mru = true, sort_lastused = true }) end, { desc = "Buffers" })
  map("<leader>fg", function() builtin.git_files({ show_untracked = true }) end, { desc = "Git files" })
  map("<leader>ff", function() builtin.find_files() end, { desc = "Find files" })
  map("<leader>fF", function() builtin.find_files({ cwd = buffer_dir() }) end, { desc = "Find files (rel)" })
  map("<leader>fr", function() builtin.oldfiles() end, { desc = "Recent" })
  map("<leader>fR", function() builtin.oldfiles({ cwd_only = true }) end, { desc = "Recent (rel)" })

  -- git
  map("<leader>gb", "<cmd>Telescope git_bcommits<cr>", { desc = "Git commits buffer" })
  map("<leader>gc", "<cmd>Telescope git_commits<cr>", { desc = "Git commits" })
  map("<leader>gs", "<cmd>Telescope git_status<cr>", { desc = "Git status" })

  -- search
  map('<leader>s"', "<cmd>Telescope registers<cr>", { desc = "Registers" })
  map("<leader>sa", "<cmd>Telescope autocommands<cr>", { desc = "Auto commands" })
  map("<leader>sb", "<cmd>Telescope current_buffer_fuzzy_find<cr>", { desc = "Buffer fuzzy" })
  map("<leader>sc", "<cmd>Telescope command_history<cr>", { desc = "Command history" })
  map("<leader>sC", "<cmd>Telescope commands<cr>", { desc = "Commands" })
  map("<leader>si", "<cmd>Telescope<cr>", { desc = "Picker builtin" })
  map("<leader>sg", function() builtin.live_grep() end, { desc = "Grep" })
  map("<leader>sG", function() builtin.live_grep({ cwd = buffer_dir() }) end, { desc = "Grep (rel)" })
  map("<leader>sh", "<cmd>Telescope help_tags<cr>", { desc = "Help pages" })
  map("<leader>sH", "<cmd>Telescope highlights<cr>", { desc = "Search highlight groups" })
  map("<leader>sj", "<cmd>Telescope jumplist<cr>", { desc = "Jumplist" })
  map("<leader>sk", "<cmd>Telescope keymaps<cr>", { desc = "Key maps" })
  map("<leader>sM", "<cmd>Telescope man_pages<cr>", { desc = "Man pages" })
  map("<leader>sm", "<cmd>Telescope marks<cr>", { desc = "Jump to mark" })
  map("<leader>so", "<cmd>Telescope vim_options<cr>", { desc = "Options" })
  map("<leader>sR", "<cmd>Telescope resume<cr>", { desc = "Resume" })
  map(
    "<leader>sS", -- c-space-space, :class:, c-l -> filter on class
    function()
      builtin.lsp_dynamic_workspace_symbols({
        symbols = require("ak.consts").get_kind_filter(),
      })
    end,
    { desc = "Goto symbol (workspace)" }
  )
  map(
    "<leader>ss",
    function()
      builtin.lsp_document_symbols({
        symbols = require("ak.consts").get_kind_filter(),
      })
    end,
    { desc = "Goto symbol" }
  )
  map("<leader>sw", function() builtin.grep_string({ word_match = "-w" }) end, { desc = "Word" })
  map(
    "<leader>sW",
    function() builtin.grep_string({ cwd = buffer_dir(), word_match = "-w" }) end,
    { desc = "Word (rel)" }
  )
  map("<leader>sw", function() builtin.grep_string() end, { desc = "Selection" }, "v")
  map("<leader>sW", function() builtin.grep_string({ cwd = buffer_dir() }) end, { desc = "Selection (rel)" }, "v")

  -- diagnostics/quickfix
  map("<leader>xd", "<cmd>Telescope diagnostics<cr>", { desc = "Workspace diagnostics" })
  map("<leader>xD", "<cmd>Telescope diagnostics bufnr=0<cr>", { desc = "Document diagnostics" })
  -- The bqf plugin needs the fzf plugin to search the quickfix. Use picker instead.
  map("<leader>xx", "<cmd> Telescope quickfix<cr>", { desc = "Quickfix search" })
  map("<leader>xX", "<cmd> Telescope quickfixhistory<cr>", { desc = "Quickfixhis search" })
  map("<leader>xz", "<cmd> Telescope loclist<cr>", { desc = "Loclist search" })
end

--          ╭─────────────────────────────────────────────────────────╮
--          │                       extensions                        │
--          ╰─────────────────────────────────────────────────────────╯
local function extensions()
  require("telescope").load_extension("fzf")
  require("telescope").load_extension("ui-select")

  -- ── alternate ─────────────────────────────────────────────────────────
  require("telescope-alternate").setup({
    mappings = {
      {
        "src/(.*)/(.*).py",
        { { "tests/**/test_[2].py", "Test", false } },
      },
      {
        "tests/(.*)/test_(.*).py",
        { { "src/**/[2].py", "Source", false } },
      },
    },
  })
  require("telescope").load_extension("telescope-alternate")
  map(
    "ml",
    function() require("telescope").extensions["telescope-alternate"].alternate_file() end,
    { desc = "Alternate file" }
  )

  -- ── zoxide ────────────────────────────────────────────────────────────
  -- require("telescope").load_extension("zoxide") -- <c-b> does not work
  -- map("<leader>fz", function()
  --   require("telescope").extensions.zoxide.list()
  -- end, { desc = "Zoxide file navigation" })

  -- ── file-browser ──────────────────────────────────────────────────────
  -- require("telescope").load_extension("file_browser")
  -- map("<leader>fB", function()
  --   require("telescope").extensions.file_browser.file_browser()
  -- end, { desc = "Telescope file_browser" })

  -- ── project ───────────────────────────────────────────────────────────
  -- require("telescope").load_extension("project") -- requires file browser
  -- map("<leader>fp", function()
  --   require("telescope").extensions.project.project()
  -- end, { desc = "Telescope Project" })

  -- ── aerial ────────────────────────────────────────────────────────────
  require("telescope").load_extension("aerial")
  -- Shows only function symbol kinds:
  map("<leader>ss", "<cmd>Telescope aerial<cr>", { desc = "Goto symbol (aerial)" })
end

local function picker()
  local builtin = require("telescope.builtin")

  ---@type Picker
  local Picker = {
    find_files = function() vim.cmd("Telescope find_files") end,
    live_grep = function() vim.cmd("Telescope live_grep") end,
    keymaps = function() vim.cmd("Telescope keymaps") end,
    oldfiles = builtin.oldfiles,
    lsp_definitions = function() vim.cmd("Telescope lsp_definitions reuse_win=true") end,
    lsp_references = function() vim.cmd("Telescope lsp_references") end,
    lsp_implementations = function() vim.cmd("Telescope lsp_implementations reuse_win=true") end,
    lsp_type_definitions = function() vim.cmd("Telescope lsp_type_definitions reuse_win=true") end,
    colors = color_picker,
    todo_comments = todo_comments,
  }
  Utils.pick.use_picker(Picker)
end
--          ╭─────────────────────────────────────────────────────────╮
--          │                          Setup                          │
--          ╰─────────────────────────────────────────────────────────╯

local function setup()
  require("telescope").setup(get_opts())
  keys()
  extensions()
  picker()
end
setup()
