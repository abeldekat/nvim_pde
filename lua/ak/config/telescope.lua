local Util = require("ak.util")

local function map(l, r, opts, mode)
  mode = mode or "n"
  opts["silent"] = opts.silent ~= false
  vim.keymap.set(mode, l, r, opts)
end

--          ╭─────────────────────────────────────────────────────────╮
--          │                      Flash support                      │
--          ╰─────────────────────────────────────────────────────────╯
local function flash(prompt_bufnr)
  require("flash").jump({
    pattern = "^",
    label = { after = { 0, 0 } },
    search = {
      mode = "search",
      exclude = {
        function(win)
          return vim.bo[vim.api.nvim_win_get_buf(win)].filetype ~= "TelescopeResults"
        end,
      },
    },
    action = function(match)
      local picker = require("telescope.actions.state").get_current_picker(prompt_bufnr)
      picker:set_selection(match.pos[1] - 1)
    end,
  })
end

--          ╭─────────────────────────────────────────────────────────╮
--          │                          Opts                           │
--          ╰─────────────────────────────────────────────────────────╯
local function get_opts()
  local actions = require("telescope.actions")
  local layout_actions = require("telescope.actions.layout")

  local open_with_trouble = function(...)
    return require("trouble.providers.telescope").open_with_trouble(...)
  end
  local open_selected_with_trouble = function(...)
    return require("trouble.providers.telescope").open_selected_with_trouble(...)
  end
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
      prompt_prefix = " ",
      selection_caret = " ",
      -- open files in the first window that is an actual file.
      -- use the current window if no other window is available.
      get_selection_window = function()
        local wins = vim.api.nvim_list_wins()
        table.insert(wins, 1, vim.api.nvim_get_current_win())
        for _, win in ipairs(wins) do
          local buf = vim.api.nvim_win_get_buf(win)
          if vim.bo[buf].buftype == "" then
            return win
          end
        end
        return 0
      end,
      layout_strategy = "flex",
      layout_config = {
        horizontal = {
          preview_width = 0.55,
        },
        vertical = {
          width = 0.9,
          height = 0.95,
          preview_height = 0.5,
          preview_cutoff = 0,
        },
        flex = {
          flip_columns = 140,
        },
      },
      mappings = {
        i = {
          ["<c-t>"] = open_with_trouble,
          ["<a-t>"] = open_selected_with_trouble,
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
  }

  if Util.has("flash.nvim") then
    opts.defaults.mappings.i["<c-s>"] = flash
    opts.defaults.mappings.n["s"] = flash
  end
  return opts
end

--          ╭─────────────────────────────────────────────────────────╮
--          │                          Keys                           │
--          ╰─────────────────────────────────────────────────────────╯
-- searching: Telescope default is vim.loop.cwd. May also be relative to buffer
local function keys()
  local builtin = require("telescope.builtin")
  local themes = require("telescope.themes")
  local buffer_dir = require("telescope.utils").buffer_dir

  -- top level, candidates to lazy-load:
  map("<leader>/", function()
    builtin.current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({
      winblend = 10,
      previewer = false,
    }))
  end, { desc = "Search in buffer" })
  map("<leader>o", function()
    builtin.buffers({ sort_mru = true, sort_lastused = true })
  end, { desc = "Opened buffers" })
  map("<leader>e", function()
    builtin.live_grep(themes.get_ivy({}))
  end, { desc = "Grep" })
  map("<leader>r", function()
    builtin.oldfiles()
  end, { desc = "Recent" })
  map("<leader>:", function()
    builtin.command_history()
  end, { desc = "Command history" })
  map("<leader><leader>", function()
    builtin.git_files({ show_untracked = true })
  end, { desc = "Git files" })

  -- find:
  map("<leader>fb", function()
    builtin.buffers({ sort_mru = true, sort_lastused = true })
  end, { desc = "Buffers" })
  map("<leader>fg", function()
    builtin.git_files({ show_untracked = true })
  end, { desc = "Git files" })
  map("<leader>ff", function()
    builtin.find_files()
  end, { desc = "Find files" })
  map("<leader>fF", function()
    builtin.find_files({ cwd = buffer_dir() })
  end, { desc = "Find files (rel)" })
  map("<leader>fr", function()
    builtin.oldfiles()
  end, { desc = "Recent" })
  map("<leader>fR", function()
    builtin.oldfiles({ cwd = buffer_dir() })
  end, { desc = "Recent (rel)" })

  -- git
  map("<leader>gb", "<cmd>Telescope git_bcommits<cr>", { desc = "bcommits" })
  map("<leader>gc", "<cmd>Telescope git_commits<cr>", { desc = "commits" })
  map("<leader>gs", "<cmd>Telescope git_status<cr>", { desc = "status" })

  -- search
  map('<leader>s"', "<cmd>Telescope registers<cr>", { desc = "Registers" })
  map("<leader>sa", "<cmd>Telescope autocommands<cr>", { desc = "Auto commands" })
  map("<leader>sb", "<cmd>Telescope current_buffer_fuzzy_find<cr>", { desc = "Buffer fuzzy" })
  map("<leader>sc", "<cmd>Telescope command_history<cr>", { desc = "Command history" })
  map("<leader>sC", "<cmd>Telescope commands<cr>", { desc = "Commands" })
  map("<leader>sd", "<cmd>Telescope diagnostics bufnr=0<cr>", { desc = "Document diagnostics" })
  map("<leader>sD", "<cmd>Telescope diagnostics<cr>", { desc = "Workspace diagnostics" })
  map("<leader>si", "<cmd>Telescope<cr>", { desc = "Telescope builtin" })
  map("<leader>sg", function()
    builtin.live_grep()
  end, { desc = "Grep" })
  map("<leader>sG", function()
    builtin.live_grep({ cwd = buffer_dir() })
  end, { desc = "Grep (rel)" })
  map("<leader>sh", "<cmd>Telescope help_tags<cr>", { desc = "Help pages" })
  map("<leader>sH", "<cmd>Telescope highlights<cr>", { desc = "Search highlight groups" })
  map("<leader>sk", "<cmd>Telescope keymaps<cr>", { desc = "Key maps" })
  map("<leader>sM", "<cmd>Telescope man_pages<cr>", { desc = "Man pages" })
  map("<leader>sm", "<cmd>Telescope marks<cr>", { desc = "Jump to mark" })
  map("<leader>so", "<cmd>Telescope vim_options<cr>", { desc = "Options" })
  map("<leader>sR", "<cmd>Telescope resume<cr>", { desc = "Resume" })
  map("<leader>sw", function()
    builtin.grep_string({ word_match = "-w" })
  end, { desc = "Word" })
  map("<leader>sW", function()
    builtin.grep_string({ cwd = buffer_dir(), word_match = "-w" })
  end, { desc = "Word (rel)" })
  map("<leader>sw", function()
    builtin.grep_string()
  end, { desc = "Selection" }, "v")
  map("<leader>sW", function()
    builtin.grep_string({ cwd = buffer_dir() })
  end, { desc = "Selection (rel)" }, "v")
  map("<leader>uC", function()
    builtin.colorscheme({ enable_preview = true })
  end, { desc = "Colorscheme with preview" })
  map("<leader>sS", function()
    builtin.lsp_dynamic_workspace_symbols({
      symbols = require("ak.misc.consts").get_kind_filter(),
    })
  end, { desc = "Goto symbol (workspace)" })
  map("<leader>ss", function()
    builtin.lsp_document_symbols({
      symbols = require("ak.misc.consts").get_kind_filter(),
    })
  end, { desc = "Goto symbol" })
end

--          ╭─────────────────────────────────────────────────────────╮
--          │                       extensions                        │
--          ╰─────────────────────────────────────────────────────────╯
local function extensions()
  require("telescope").load_extension("fzf")

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
  map("ml", function()
    require("telescope").extensions["telescope-alternate"].alternate_file()
  end, { desc = "Alternate file" })

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
  map("<leader>ss", "<cmd>Telescope aerial<cr>", { desc = "Goto symbol (aerial)" })
end

--          ╭─────────────────────────────────────────────────────────╮
--          │                          Setup                          │
--          ╰─────────────────────────────────────────────────────────╯

local function setup()
  require("telescope").setup(get_opts())
  keys()
  extensions()
end

setup()
