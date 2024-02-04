local Util = require("ak.util")
local add, later = vim.cmd.packadd, Util.defer.later

if Util.submodules.is_provisioning() then
  Util.info("------> Start provisioning treesitter")

  add("nvim-treesitter")
  add("nvim-treesitter-textobjects")

  -- This is slow the first time:
  require("ak.config.treesitter") -- has ensure_installed

  vim.cmd("TSUpdateSync") -- update to the latest versions
  return
end

later(function()
  add("nvim-treesitter")
  add("nvim-treesitter-textobjects")
  require("ak.config.treesitter")

  add("nvim-ts-autotag")
  require("ak.config.treesitter_autotag")

  add("nvim-treesitter-context")
  require("ak.config.treesitter_context")
end)
