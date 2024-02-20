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

--          ╭─────────────────────────────────────────────────────────╮
--          │                      Provisioning                       │
--          ╰─────────────────────────────────────────────────────────╯

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

--          ╭─────────────────────────────────────────────────────────╮
--          │    Using the "later" function present in the neovim     │
--          │                 config of @echasnovski                  │
--          │         See the acknowledgements in the README          │
--          ╰─────────────────────────────────────────────────────────╯

local H = {}

-- Various cache
H.cache = {
  -- Whether finish of `later()` is already scheduled
  finish_is_scheduled = false,

  -- Callback queue for `later()`
  later_callback_queue = {},

  -- Errors during execution of `later()`
  exec_errors = {},
}

M.later = function(f)
  table.insert(H.cache.later_callback_queue, f)
  H.schedule_finish()
end

-- Indicating usage only needed when using later
M.later_only = function(f) M.later(f) end

H.now = function(f)
  local ok, err = pcall(f)
  if not ok then table.insert(H.cache.exec_errors, err) end
  H.schedule_finish()
end

H.schedule_finish = function()
  if H.cache.finish_is_scheduled then return end
  vim.schedule(H.finish)
  H.cache.finish_is_scheduled = true
end

H.finish = function()
  local timer, step_delay = vim.loop.new_timer(), 1
  local f = nil
  f = vim.schedule_wrap(function()
    local callback = H.cache.later_callback_queue[1]
    if callback == nil then
      H.cache.finish_is_scheduled, H.cache.later_callback_queue = false, {}
      H.report_errors()
      return
    end

    table.remove(H.cache.later_callback_queue, 1)

    H.now(callback)

    ---@diagnostic disable-next-line: param-type-mismatch
    timer:start(step_delay, 0, f)
  end)
  timer:start(step_delay, 0, f)
end

H.report_errors = function()
  if #H.cache.exec_errors == 0 then return end

  -- vim.api.nvim_echo(H.cache.exec_errors, true, {})
  local error = require("ak.util").error
  for _, msg in ipairs(H.cache.exec_errors) do
    error(msg)
  end
  H.cache.exec_errors = {}
end
return M
