local Util = require("ak.util")
local with_dir = Util.opened_with_dir_argument()
-- local lazyfile = { "BufReadPost", "BufNewFile", "BufWritePre" }

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
    event = "VeryLazy",
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
    cmd = "Telescope", -- used by the menu in the intro screen
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

  -- ── previously lazyfile ───────────────────────────────────────────────

  {
    "lewis6991/gitsigns.nvim",
    event = "VeryLazy",
    config = function()
      require("ak.config.gitsigns")
    end,
  },

  {
    "RRethy/vim-illuminate",
    event = "VeryLazy",
    config = function()
      require("ak.config.illuminate")
    end,
  },
  {
    "folke/todo-comments.nvim",
    event = "VeryLazy",
    config = function()
      require("ak.config.todo_comments")
    end,
  },

  -- ── on-demand ─────────────────────────────────────────────────────────

  {
    "f-person/git-blame.nvim", -- toggle
    keys = { { "<leader>gt", desc = "Git-blame" } },
    config = function()
      require("ak.config.gitblame")
    end,
  },

  {
    "takac/vim-hardtime", -- toggle
    keys = { { "<leader>uh", desc = "Hardtime" } },
    config = function()
      require("ak.config.hardtime")
    end,
  },
}
