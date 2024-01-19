local M = {}

local treesitter_spec = {
  "windwp/nvim-ts-autotag",
  "nvim-treesitter/nvim-treesitter-context",
  "nvim-treesitter/nvim-treesitter-textobjects",
  { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },
}

function M.spec()
  return treesitter_spec
end

function M.setup()
  require("nvim-ts-autotag").setup() -- event
  require("ak.config.treesitter_context") -- event

  require("ak.config.treesitter_textobjects") -- dep of treesitter
  require("ak.config.treesitter") -- event, command, keys
end

return M
