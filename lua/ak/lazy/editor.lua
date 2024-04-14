--          ╭─────────────────────────────────────────────────────────╮
--          │          Contains plugins enhancing the editor          │
--          │       Main components: Harpoon, telescope and oil       │
--          ╰─────────────────────────────────────────────────────────╯

local Util = require("ak.util")
local with_dir = Util.opened_with_dir_argument()

return {

  {
    "ggandor/leap.nvim",
    event = "VeryLazy",
    dependencies = {
      "tpope/vim-repeat",
      "ggandor/leap-spooky.nvim",
      "jinh0/eyeliner.nvim",
    },
    config = function()
      require("ak.config.editor.leap")
      require("ak.config.editor.eyeliner")
    end,
  },

  --          ╭─────────────────────────────────────────────────────────╮
  --          │  Have both harpoon and grapple installed, but use only  │
  --          │                         one...                          │
  --          ╰─────────────────────────────────────────────────────────╯
  {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    -- event = "VeryLazy",
    -- config = function() require("ak.config.editor.harpoon") end,
  },
  {
    -- "abeldekat/grapple.nvim",
    "cbochs/grapple.nvim",
    event = "VeryLazy",
    config = function() require("ak.config.editor.grapple") end,
  },

  {
    "stevearc/oil.nvim",
    init = function()
      if with_dir then require("oil") end
    end,
    event = function() return not with_dir and { "VeryLazy" } or {} end,
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("ak.config.editor.oil")

      --          ╭─────────────────────────────────────────────────────────╮
      --          │          Efficiency: Also setup mini plugins:           │
      --          ╰─────────────────────────────────────────────────────────╯
      require("ak.config.editor.mini_clue")
      require("ak.config.editor.mini_misc") -- zoom buffer
      require("ak.config.editor.mini_cursorword")
      require("ak.config.editor.mini_hipatterns")
    end,
  },

  {
    "nvim-telescope/telescope.nvim",
    event = "VeryLazy",
    -- branch = "0.1.x",  -- kickstart
    dependencies = { -- extensions: Also uses flash!
      "nvim-telescope/telescope-ui-select.nvim", -- replacing dressing.nvim
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
      {
        "nvim-pack/nvim-spectre",
        build = false,
        config = function() require("ak.config.editor.spectre") end,
      },
      {
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

  {
    "lewis6991/gitsigns.nvim",
    event = "VeryLazy",
    config = function() require("ak.config.editor.gitsigns") end,
  },

  -- ── on-demand ─────────────────────────────────────────────────────────

  {
    "f-person/git-blame.nvim", -- toggle
    keys = { { "<leader>gt", desc = "Git-blame" } },
    config = function() require("ak.config.editor.gitblame") end,
  },

  {
    "takac/vim-hardtime", -- toggle
    keys = { { "<leader>uH", desc = "Hardtime" } },
    config = function() require("ak.config.editor.hardtime") end,
  },
}
