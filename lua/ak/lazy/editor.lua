--          ╭─────────────────────────────────────────────────────────╮
--          │          Contains plugins enhancing the editor          │
--          │       Main components: Harpoon, telescope and oil       │
--          ╰─────────────────────────────────────────────────────────╯

local Util = require("ak.util")
local with_dir = Util.opened_with_dir_argument()

return {

  -- ── verylazy ──────────────────────────────────────────────────────────

  {
    "folke/flash.nvim",
    event = "VeryLazy",
    dependencies = "jinh0/eyeliner.nvim",
    config = function() require("ak.config.editor.flash") end,
  },

  {
    "ThePrimeagen/harpoon",
    -- branch = "harpoon2",
    event = "VeryLazy",
    config = function()
      -- require("ak.config.harpoon")
      require("ak.config.editor.harpoon_one")
    end,
  },

  {
    "echasnovski/mini.clue",
    event = "VeryLazy",
    config = function() require("ak.config.editor.mini_clue") end,
  },

  {
    "stevearc/oil.nvim",
    init = function()
      if with_dir then require("oil") end
    end,
    event = function() return not with_dir and { "VeryLazy" } or {} end,
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function() require("ak.config.editor.oil") end,
  },

  {
    "nvim-telescope/telescope.nvim",
    event = "VeryLazy",
    dependencies = { -- extensions: Also uses flash!
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "make",
        enabled = vim.fn.executable("make") == 1,
      },
      "otavioschwanck/telescope-alternate.nvim",
      -- "jvgrootveld/telescope-zoxide",
      -- {
      --   "nvim-telescope/telescope-project.nvim",
      --   dependencies = "nvim-telescope/telescope-file-browser.nvim",
      -- },
      {
        "stevearc/aerial.nvim",
        config = function() require("ak.config.editor.aerial") end,
      },
      { -- also load spectre on telescope
        "nvim-pack/nvim-spectre",
        build = false,
        config = function() require("ak.config.editor.spectre") end,
      },
      { -- also load trouble on telescope
        "folke/trouble.nvim",
        config = function() require("ak.config.editor.trouble") end,
      },
    },
    config = function() require("ak.config.editor.telescope") end,
  },

  {
    "akinsho/toggleterm.nvim",
    version = "*",
    event = "VeryLazy",
    config = function() require("ak.config.editor.toggleterm") end,
  },

  -- ── previously lazyfile ───────────────────────────────────────────────
  -- local lazyfile = { "BufReadPost", "BufNewFile", "BufWritePre" }

  {
    "lewis6991/gitsigns.nvim",
    event = "VeryLazy",
    config = function() require("ak.config.editor.gitsigns") end,
  },

  {
    "RRethy/vim-illuminate",
    event = "VeryLazy",
    config = function() require("ak.config.editor.illuminate") end,
  },
  {
    "folke/todo-comments.nvim",
    event = "VeryLazy",
    config = function() require("ak.config.editor.todo_comments") end,
  },

  -- ── on-demand ─────────────────────────────────────────────────────────

  {
    "f-person/git-blame.nvim", -- toggle
    keys = { { "<leader>gt", desc = "Git-blame" } },
    config = function() require("ak.config.editor.gitblame") end,
  },

  {
    "takac/vim-hardtime", -- toggle
    keys = { { "<leader>uh", desc = "Hardtime" } },
    config = function() require("ak.config.editor.hardtime") end,
  },
}
