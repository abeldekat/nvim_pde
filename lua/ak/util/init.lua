---@class ak.util
---@field color ak.util.color
---@field defer ak.util.defer
---@field deps ak.util.deps
---@field lsp ak.util.lsp
---@field toggle ak.util.toggle
local M = {}

setmetatable(M, {
  __index = function(t, k)
    ---@diagnostic disable-next-line: no-unknown
    t[k] = require("ak.util." .. k)
    return t[k]
  end,
})

---@type string[]
local referenced_plugins = {}

-- Register the name of a plugin that is also referenced in modules other than their own
-- Those modules must be loaded after the plugin has registered itself.
---@param plugin string
function M.register_referenced(plugin) table.insert(referenced_plugins, plugin) end

---@param plugin string
function M.has(plugin) return vim.tbl_contains(referenced_plugins, plugin) end

-- This indicates that oil.nvim should be shown
function M.opened_with_dir_argument()
  if vim.fn.argc() == 1 then
    ---@diagnostic disable-next-line: param-type-mismatch
    local stat = vim.uv.fs_stat(vim.fn.argv(0))
    if stat and stat.type == "directory" then return true end
  end
  return false
end

-- This indicates that the dashboard should be shown.
function M.opened_without_arguments()
  if vim.fn.argc() > 0 then return false end
  return true
end

-- This indicates that some lazy plugins might have missed an event
function M.opened_with_file_argument()
  return not (M.opened_without_arguments() or M.opened_with_dir_argument()) --
end

function M.is_headless() return #vim.api.nvim_list_uis() == 0 end

--          ╭─────────────────────────────────────────────────────────╮
--          │             Copied code from lazy.core.util             │
--          ╰─────────────────────────────────────────────────────────╯

---@alias AkNotifyOpts {title?:string, level?:number, once?:boolean}

---@param msg string|string[]
---@param opts? AkNotifyOpts
local function notify(msg, opts)
  if vim.in_fast_event() then return vim.schedule(function() notify(msg, opts) end) end

  opts = opts or {}
  if type(msg) == "table" then
    msg = table.concat(vim.tbl_filter(function(line) return line or false end, msg), "\n")
  end
  local n = opts.once and vim.notify_once or vim.notify
  n(msg, opts.level or vim.log.levels.INFO, {
    title = opts.title or "nvim_pde",
  })
end

---@param msg string|string[]
---@param opts? AkNotifyOpts
function M.error(msg, opts)
  opts = opts or {}
  opts.level = vim.log.levels.ERROR
  notify(msg, opts)
end

---@param msg string|string[]
---@param opts? AkNotifyOpts
function M.info(msg, opts)
  opts = opts or {}
  opts.level = vim.log.levels.INFO
  notify(msg, opts)
end

---@param msg string|string[]
---@param opts? AkNotifyOpts
function M.warn(msg, opts)
  opts = opts or {}
  opts.level = vim.log.levels.WARN
  notify(msg, opts)
end

---@param opts? string|{msg:string, on_error:fun(msg)}
function M.try(fn, opts)
  opts = type(opts) == "string" and { msg = opts } or opts or {}
  local msg = opts.msg
  -- error handler
  local error_handler = function(err)
    msg = (msg and (msg .. "\n\n") or "") .. err
    if opts.on_error then
      opts.on_error(msg)
    else
      vim.schedule(function() M.error(msg) end)
    end
    return err
  end

  ---@type boolean, any
  local ok, result = xpcall(fn, error_handler)
  return ok and result or nil
end

return M
