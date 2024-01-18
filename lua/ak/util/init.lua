---@class ak.util
---@field ui ak.util.ui
---@field lsp ak.util.lsp
---@field toggle ak.util.toggle
---@field plugin ak.util.lazy_file
local M = {}

setmetatable(M, {
  __index = function(t, k)
    ---@diagnostic disable-next-line: no-unknown
    t[k] = require("ak.util." .. k) -- implemented in submodule
    return t[k]
  end,
})

---@param plugin string
function M.has(plugin)
  return vim.tbl_contains({ "trouble.nvim", "flash.nvim", "eyeliner.nvim", "nvim-dap-python" }, plugin)
end

--          ╭─────────────────────────────────────────────────────────╮
--          │             Copied code from lazy.core.util             │
--          ╰─────────────────────────────────────────────────────────╯

---@alias AkNotifyOpts {title?:string, level?:number, once?:boolean}

---@param msg string|string[]
---@param opts? AkNotifyOpts
local function notify(msg, opts)
  if vim.in_fast_event() then
    return vim.schedule(function()
      notify(msg, opts)
    end)
  end

  opts = opts or {}
  if type(msg) == "table" then
    msg = table.concat(
      vim.tbl_filter(function(line)
        return line or false
      end, msg),
      "\n"
    )
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
      vim.schedule(function()
        M.error(msg)
      end)
    end
    return err
  end

  ---@type boolean, any
  local ok, result = xpcall(fn, error_handler)
  return ok and result or nil
end

return M
