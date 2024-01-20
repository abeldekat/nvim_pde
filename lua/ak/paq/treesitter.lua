local Util = require("ak.util")

local M = {}

local treesitter_spec = {
  { "windwp/nvim-ts-autotag", opt = true },
  { "nvim-treesitter/nvim-treesitter-context", opt = true },
  { "nvim-treesitter/nvim-treesitter-textobjects", opt = true },
  { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate", opt = true },
}

local function lazyfile()
  return { "BufReadPost", "BufNewFile", "BufWritePre" }
end

local function verylazy()
  return "UIEnter"
end

local function verylazy_and_lazyfile()
  local result = lazyfile()
  table.insert(result, verylazy())
  return result
end

local function load_treesitter()
  vim.cmd.packadd("nvim-treesitter")
  vim.cmd.packadd("nvim-treesitter-textobjects")
  require("ak.config.treesitter")
end

function M.spec()
  Util.paq.on_command(function()
    load_treesitter()
  end, "TSUpdate")

  return treesitter_spec
end

function M.setup()
  Util.paq.on_events(function()
    load_treesitter()
  end, verylazy_and_lazyfile())

  Util.paq.on_events(function()
    vim.cmd.packadd("nvim-ts-autotag")
    require("nvim-ts-autotag").setup()

    vim.cmd.packadd("nvim-treesitter-context")
    require("ak.config.treesitter_context")
  end, lazyfile())
end

return M
