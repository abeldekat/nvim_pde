local Util = require("ak.util")
local autoload_clues = true
local with_dir = Util.opened_with_dir_argument()

local function no_op() end
return {

  -- ── verylazy ──────────────────────────────────────────────────────────

  {
    "folke/flash.nvim",
    event = "VeryLazy",
    dependencies = "jinh0/eyeliner.nvim",
    config = function()
      require("ak.config.jump")
    end,
  },

  {
    "ThePrimeagen/harpoon",
    -- branch = "harpoon2",
    event = "VeryLazy",
    config = function()
      -- require("ak.config.harpoon")
      require("ak.config.harpoon_one")
    end,
  },

  {
    "echasnovski/mini.clue",
    event = function()
      return autoload_clues and { "VeryLazy" } or {}
    end,
    config = function()
      require("ak.config.clue")
    end,
  },

  {
    "stevearc/oil.nvim",
    init = function()
      if with_dir then
        require("oil")
      end
    end,
    event = function()
      return not with_dir and { "VeryLazy" } or {}
    end,
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("ak.config.oil")
    end,
  },

  {
    "nvim-telescope/telescope.nvim",
    cmd = "Telescope", -- used by the keys in the intro screen
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
        config = function()
          require("ak.config.aerial")
        end,
      },
      { -- also load spectre on telescope
        "nvim-pack/nvim-spectre",
        build = false,
        config = function()
          require("ak.config.spectre")
        end,
      },
      { -- also load trouble on telescope
        "folke/trouble.nvim",
        config = function()
          require("ak.config.trouble")
        end,
      },
    },
    config = function()
      require("ak.config.telescope")
    end,
  },

  {
    "akinsho/toggleterm.nvim",
    version = "*",
    event = "VeryLazy",
    config = function()
      require("ak.config.toggleterm")
    end,
  },

  -- ── lazyfile ──────────────────────────────────────────────────────────

  {
    "lewis6991/gitsigns.nvim",
    event = "LazyFile",
    config = function()
      require("ak.config.gitsigns")
    end,
  },

  {
    "RRethy/vim-illuminate",
    event = "LazyFile",
    config = function()
      require("ak.config.illuminate")
    end,
  },
  {
    "folke/todo-comments.nvim",
    event = "LazyFile",
    config = function()
      require("ak.config.todo_comments")
    end,
  },

  -- ── on-demand ─────────────────────────────────────────────────────────

  {
    "f-person/git-blame.nvim", -- toggle
    keys = { { "<leader>gt", no_op(), desc = "Git-blame" } },
    config = function()
      require("ak.config.gitblame")
    end,
  },

  {
    "takac/vim-hardtime", -- toggle
    keys = { { "<leader>uh", no_op, desc = "Hardtime" } },
    config = function()
      require("ak.config.hardtime")
    end,
  },
}
