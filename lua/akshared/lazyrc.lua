--[[
Enable project-specific plugin specs.

File .lazy.lua:
  is read when present in the current working directory
  should return a plugin spec
  has to be manually trusted for each instance of the file

See:
  :h 'exrc'
  :h :trust
--]]

local M = {}
local is_initialized = false

---@type table[table<string, function>]
local cache = {}

local function initialize()
  is_initialized = true

  local filepath = vim.fn.fnamemodify(".lazy.lua", ":p")
  local file = vim.secure.read(filepath)
  if not file then return end

  ---@diagnostic disable-next-line: param-type-mismatch
  local lazyspec = loadstring(file)() -- this could error when a require is not inside a function...
  if not lazyspec then return end
  lazyspec = type(lazyspec[1]) == "string" and { lazyspec } or lazyspec

  for _, spec in ipairs(lazyspec) do
    local name = spec[1]
    if not name or not type(name) == "string" then break end

    local sep = string.find(name, "/")
    name = sep and string.sub(name, sep) or name
    local opts = spec.opts
    if not opts then break end

    table.insert(cache, { name, opts })
  end
end

M.merge_opts = function(module_name, opts)
  if not is_initialized then initialize() end
  if #cache == 0 then return opts end

  local filtered = vim.tbl_filter(function(item) return string.find(item[1], module_name) ~= nil end, cache)
  if not filtered or #filtered ~= 1 then return opts end

  local item = filtered[1]
  local extra_opts = item[2]
  if not type(extra_opts) == "function" then return opts end -- only assume a function for now

  local result = extra_opts(nil, opts)
  return result and result or opts
end

return M
