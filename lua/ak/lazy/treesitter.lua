-- local Util = require("ak.util")
-- local function lazyfile()
--   return { "BufReadPost", "BufNewFile", "BufWritePre" }
-- end

return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    dependencies = {
      "nvim-treesitter/nvim-treesitter-textobjects",
      config = function()
        require("ak.config.treesitter_textobjects")
      end,
    },
    event = "VeryLazy",
    -- event = function()
    --   return Util.opened_without_arguments() and { "VeryLazy" } or lazyfile()
    -- end,
    config = function()
      require("ak.config.treesitter")
    end,
  },

  {
    "windwp/nvim-ts-autotag",
    -- event = lazyfile(),
    event = "VeryLazy",
    config = function()
      require("ak.config.treesitter_autotag")
    end,
  },

  {
    "nvim-treesitter/nvim-treesitter-context",
    -- event = lazyfile(),
    event = "VeryLazy",
    config = function()
      require("ak.config.treesitter_context")
    end,
  },
}
