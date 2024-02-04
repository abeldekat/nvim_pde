---@class ak.util.submodules
local M = {}

-- Give a unit and a subpath, returns the full path of the file in pack
---@param unit string
---@param path_after_opt string[]
---@return string
function M.file_in_pack_path(unit, path_after_opt)
  -- stylua: ignore
  local filename = require("plenary.path"):new(
    vim.list_extend({ vim.fn.stdpath("config"), "pack", unit .. "_ak", "opt" }, path_after_opt)
  ).filename
  return filename
end

-- Neovim is started in provisioning mode
-- The aim is to build plugins
-- This is comparable to lazy.nvim's plugin.build property
function M.is_provisioning()
  return vim.g.ak_provisioning
end

return M
