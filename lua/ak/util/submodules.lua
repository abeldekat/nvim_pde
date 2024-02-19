---@class ak.util.submodules
local M = {}
local pack_path = vim.fn.stdpath("config") .. "/pack"

-- Given a unit and a subpath, returns the full path of the plugin in the pack folder
---@param plugin_name string
---@param unit string
---@return string
function M.plugin_path(plugin_name, unit)
  local plugin_dir = string.format("%s/%s_ak/opt/%s", pack_path, unit, plugin_name)
  return plugin_dir
end

-- Execute 'after/' scripts if not during startup (when they will be sourced
-- automatically), as `:packadd` only sources plain 'plugin/' files.
-- See https://github.com/vim/vim/issues/1994.
function M.source_after(plugin_name, unit)
  local plugin_dir = M.plugin_path(plugin_name, unit)
  local after_paths = vim.fn.glob(plugin_dir .. "/after/plugin/**/*.{vim,lua}", false, true)
  vim.tbl_map(function(p)
    vim.cmd("source " .. vim.fn.fnameescape(p)) --
  end, after_paths)
end

-- Neovim is started in provisioning mode
-- The aim is to build plugins
-- This is comparable to lazy.nvim's plugin.build property
function M.is_provisioning() return vim.g.ak_provisioning end

function M.print_provision(name)
  -- stylua: ignore start
  vim.print("--          ╭─────────────────────────────────────────────────────────╮")
  vim.print("--                         Start provisioning unit " ..  name )
  vim.print("--          ╰─────────────────────────────────────────────────────────╯")
  -- stylua: ignore end
end

return M
