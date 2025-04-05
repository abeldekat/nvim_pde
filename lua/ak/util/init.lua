---@class ak.util
---@field color ak.util.color
---@field color_lazygit ak.util.color_lazygit
---@field defer ak.util.defer
---@field deps ak.util.deps
---@field lazyrc ak.util.lazyrc
---@field pick ak.util.pick
---@field toggle ak.util.toggle
local M = {}

-- Start shared variables, overridden in ak.deps.coding and used in ak.config:

---@type boolean for the integration of treesitter textobjects and mini.ai
M.use_mini_ai = false

---@type "blink" | "mini" | "none"
M.completion = "none"

-- End shared variables

setmetatable(M, {
  __index = function(t, k)
    ---@diagnostic disable-next-line: no-unknown
    t[k] = require("ak.util." .. k)
    return t[k]
  end,
})

local argc = vim.fn.argc()
local has_one_single_dir_arg = (function() -- explorer
  if argc == 1 then
    ---@diagnostic disable-next-line: param-type-mismatch
    local stat = vim.uv.fs_stat(vim.fn.argv(0))
    if stat and stat.type == "directory" then return true end
  end
  return false
end)()

M.opened_with_arguments = function() return argc > 0 end
M.opened_with_dir_argument = function() return has_one_single_dir_arg end

M.full_path_of_current_buffer = function()
  return vim.fn.expand("%:p") -- /home/user....
end

--          ╭─────────────────────────────────────────────────────────╮
--          │             Copied code from lazy.core.util             │
--          ╰─────────────────────────────────────────────────────────╯

---@alias AkNotifyOpts {title?:string, level?:number, once?:boolean}

---@param msg string|string[]
---@param opts? AkNotifyOpts
local function notify(msg, opts)
  if vim.in_fast_event() then
    return vim.schedule(function() notify(msg, opts) end)
  end

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
