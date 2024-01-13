-- See also: aerial, flash

local Util = require("ak.util")
-- if true then return {} end

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
    Util.telescope("find_files", { no_ignore = true, default_text = line })()
  end
  local find_files_with_hidden = function()
    local action_state = require("telescope.actions.state")
    local line = action_state.get_current_line()
    Util.telescope("find_files", { hidden = true, default_text = line })()
  end

  if Util.has("aerial.nvim") then
    Util.on_load("telescope.nvim", function()
      require("telescope").load_extension("aerial")
    end)
  end

  local result = {
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
    result.defaults.mappings.i["<c-s>"] = flash
    result.defaults.mappings.n["s"] = flash
  end
  return result
end

local function get_deps()
  return {
    {
      "nvim-telescope/telescope-fzf-native.nvim",
      build = "make",
      enabled = vim.fn.executable("make") == 1,
      config = function()
        Util.on_load("telescope.nvim", function()
          require("telescope").load_extension("fzf")
        end)
      end,
    },

    {
      "otavioschwanck/telescope-alternate.nvim",
      keys = {
        {
          "ml",
          function()
            require("telescope").extensions["telescope-alternate"].alternate_file()
          end,
          desc = "Alternate file",
        },
      },
      config = function()
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
      end,
    },

    -- {
    --   "nvim-telescope/telescope-project.nvim",
    --   dependencies = "telescope-file-browser.nvim",
    --   keys = {
    --     {
    --       "<leader>fp",
    --       function()
    --         require("telescope").extensions.project.project()
    --       end,
    --       desc = "Telescope Project",
    --     },
    --   },
    --   config = function()
    --     require("telescope").load_extension("project")
    --   end,
    -- },

    -- {
    --   "nvim-telescope/telescope-file-browser.nvim",
    --   keys = {
    --     {
    --       "<space>fB",
    --       function()
    --         require("telescope").extensions.file_browser.file_browser()
    --       end,
    --       desc = "Telescope file_browser",
    --     },
    --   },
    --   config = function()
    --     require("telescope").load_extension("file_browser")
    --   end,
    -- },

    -- {
    --   "jvgrootveld/telescope-zoxide", -- <c-b> does not work
    --   keys = {
    --     {
    --       "<space>fz",
    --       function()
    --         require("telescope").extensions.zoxide.list()
    --       end,
    --       desc = "Zoxide file navigation",
    --     },
    --   },
    --   config = function()
    --     require("telescope").load_extension("zoxide")
    --   end,
    -- },
  }
end

local function get_keys()
  return function() -- needs to be a function when using Util.has...
    local keys = {
      {
        "<leader>/",
        function()
          require("telescope.builtin").current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({
            winblend = 10,
            previewer = false,
          }))
        end,
        desc = "Search in buffer",
      },
      {
        "<leader>o",
        "<cmd>Telescope buffers sort_mru=true sort_lastused=true<cr>",
        desc = "Opened buffers",
      },
      {
        "<leader>e",

        function()
          Util.telescope("live_grep", require("telescope.themes").get_ivy({}))()
        end,
        desc = "Grep (root dir)",
      },
      { -- oldfiles, from "leader fR":
        "<leader>r",
        function()
          Util.telescope("oldfiles", { cwd = vim.loop.cwd() })()
        end,
        desc = "Recent (cwd)",
      },
      { "<leader>:", "<cmd>Telescope command_history<cr>", desc = "Command history" },
      { "<leader><space>", Util.telescope("files"), desc = "Find files (root dir)" },

      -- find
      { "<leader>fb", "<cmd>Telescope buffers sort_mru=true sort_lastused=true<cr>", desc = "Buffers" },
      { "<leader>fc", Util.telescope.config_files(), desc = "Find config file" },
      { "<leader>ff", Util.telescope("files"), desc = "Find files (root dir)" },
      { "<leader>fF", Util.telescope("files", { cwd = false }), desc = "Find files (cwd)" },
      { "<leader>fr", "<cmd>Telescope oldfiles<cr>", desc = "Recent" },
      { "<leader>fR", Util.telescope("oldfiles", { cwd = vim.loop.cwd() }), desc = "Recent (cwd)" },
      -- git
      { "<leader>gb", "<cmd>Telescope git_bcommits<cr>", desc = "bcommits" },
      { "<leader>gc", "<cmd>Telescope git_commits<CR>", desc = "commits" },
      { "<leader>gs", "<cmd>Telescope git_status<CR>", desc = "status" },
      -- search
      { '<leader>s"', "<cmd>Telescope registers<cr>", desc = "Registers" },
      { "<leader>sa", "<cmd>Telescope autocommands<cr>", desc = "Auto commands" },
      { "<leader>sb", "<cmd>Telescope current_buffer_fuzzy_find<cr>", desc = "Buffer fuzzy" },
      { "<leader>sc", "<cmd>Telescope command_history<cr>", desc = "Command history" },
      { "<leader>sC", "<cmd>Telescope commands<cr>", desc = "Commands" },
      { "<leader>sd", "<cmd>Telescope diagnostics bufnr=0<cr>", desc = "Document diagnostics" },
      { "<leader>sD", "<cmd>Telescope diagnostics<cr>", desc = "Workspace diagnostics" },
      { "<leader>si", "<cmd>Telescope<cr>", desc = "Telescope builtin" },
      { "<leader>sg", Util.telescope("live_grep"), desc = "Grep (root dir)" },
      { "<leader>sG", Util.telescope("live_grep", { cwd = false }), desc = "Grep (cwd)" },
      { "<leader>sh", "<cmd>Telescope help_tags<cr>", desc = "Help pages" },
      { "<leader>sH", "<cmd>Telescope highlights<cr>", desc = "Search highlight groups" },
      { "<leader>sk", "<cmd>Telescope keymaps<cr>", desc = "Key maps" },
      { "<leader>sM", "<cmd>Telescope man_pages<cr>", desc = "Man pages" },
      { "<leader>sm", "<cmd>Telescope marks<cr>", desc = "Jump to mark" },
      { "<leader>so", "<cmd>Telescope vim_options<cr>", desc = "Options" },
      { "<leader>sR", "<cmd>Telescope resume<cr>", desc = "Resume" },
      { "<leader>sw", Util.telescope("grep_string", { word_match = "-w" }), desc = "Word (root dir)" },
      { "<leader>sW", Util.telescope("grep_string", { cwd = false, word_match = "-w" }), desc = "Word (cwd)" },
      { "<leader>sw", Util.telescope("grep_string"), mode = "v", desc = "Selection (root dir)" },
      { "<leader>sW", Util.telescope("grep_string", { cwd = false }), mode = "v", desc = "Selection (cwd)" },
      { "<leader>uC", Util.telescope("colorscheme", { enable_preview = true }), desc = "Colorscheme with preview" },
      {
        "<leader>sS",
        function()
          require("telescope.builtin").lsp_dynamic_workspace_symbols({
            symbols = require("ak.misc.consts").get_kind_filter(),
          })
        end,
        desc = "Goto symbol (workspace)",
      },
    }

    if Util.has("aerial.nvim") then
      table.insert(keys, {
        "<leader>ss",
        "<cmd>Telescope aerial<cr>",
        desc = "Goto symbol (aerial)",
      })
    else
      table.insert(keys, {
        "<leader>ss",
        function()
          require("telescope.builtin").lsp_document_symbols({
            symbols = require("ak.misc.consts").get_kind_filter(),
          })
        end,
        desc = "Goto symbol",
      })
    end
    return keys
  end
end

return {
  {
    "nvim-telescope/telescope.nvim",
    cmd = "Telescope",
    version = false, -- telescope did only one release, so use HEAD for now
    dependencies = get_deps(),
    keys = get_keys(),
    config = function()
      require("telescope").setup(get_opts())
    end,
  },
}
