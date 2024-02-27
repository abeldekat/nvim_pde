--          ╭─────────────────────────────────────────────────────────╮
--          │          DEPRECATED in favor of mini.comment            │
--          ╰─────────────────────────────────────────────────────────╯

--          ╭─────────────────────────────────────────────────────────╮
--          │                        lazy.nvim                        │
--          ╰─────────────────────────────────────────────────────────╯
-- {
--   "numToStr/Comment.nvim",
--   event = "VeryLazy",
--   dependencies = { "JoosepAlviste/nvim-ts-context-commentstring" },
--   config = function() require("ak.config.coding.comment") end,
-- },

--          ╭─────────────────────────────────────────────────────────╮
--          │                        mini.deps                        │
--          ╰─────────────────────────────────────────────────────────╯

-- add({ source = "numToStr/Comment.nvim", depends = { "JoosepAlviste/nvim-ts-context-commentstring" } })
-- require("ak.config.coding.comment")

-- the plugin itself creates the gc and gb mappings

---@diagnostic disable-next-line: missing-fields
require("ts_context_commentstring").setup({
  enable_autocmd = false,
})

local commentstring_avail, commentstring = pcall(require, "ts_context_commentstring.integrations.comment_nvim")
local opts = commentstring_avail and commentstring and { pre_hook = commentstring.create_pre_hook() } or {}
require("Comment").setup(opts)
