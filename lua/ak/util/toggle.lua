--          ╭─────────────────────────────────────────────────────────╮
--          │       Almost exact copy of lazyvim.util.toggle          │
--          ╰─────────────────────────────────────────────────────────╯

local Util = require("ak.util")

---@class ak.util.toggle
local M = {}

---@param silent boolean?
---@param values? {[1]:any, [2]:any}
function M.option(option, silent, values)
  if values then
    if vim.opt_local[option]:get() == values[1] then
      ---@diagnostic disable-next-line: no-unknown
      vim.opt_local[option] = values[2]
    else
      ---@diagnostic disable-next-line: no-unknown
      vim.opt_local[option] = values[1]
    end
    return Util.info("Set " .. option .. " to " .. vim.opt_local[option]:get(), { title = "Option" })
  end
  ---@diagnostic disable-next-line: no-unknown
  vim.opt_local[option] = not vim.opt_local[option]:get()
  if not silent then
    if vim.opt_local[option]:get() then
      Util.info("Enabled " .. option, { title = "Option" })
    else
      Util.warn("Disabled " .. option, { title = "Option" })
    end
  end
end

local nu = { number = true, relativenumber = true }
function M.number()
  ---@diagnostic disable-next-line: undefined-field
  if vim.opt_local.number:get() or vim.opt_local.relativenumber:get() then
    ---@diagnostic disable-next-line: undefined-field
    nu = { number = vim.opt_local.number:get(), relativenumber = vim.opt_local.relativenumber:get() }
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
    Util.warn("Disabled line numbers", { title = "Option" })
  else
    vim.opt_local.number = nu.number
    vim.opt_local.relativenumber = nu.relativenumber
    Util.info("Enabled line numbers", { title = "Option" })
  end
end

function M.diagnostic()
  local enabled = not vim.diagnostic.is_enabled()
  vim.diagnostic.enable(enabled)
  Util.info(string.format("Diagnostic %s", enabled and "enabled" or "disabled"), { title = "Diagnostic" })
end

---@param buf? number
---@param value? boolean
function M.inlay_hints(buf, value)
  local ih = vim.lsp.inlay_hint
  if type(ih) == "table" and ih.enable then
    if value == nil then value = not ih.is_enabled({ bufnr = buf or 0 }) end
    ih.enable(value, { bufnr = buf }) -- bufnr nil: ... for all ...
  end
end

function M.quickfix()
  local quickfix_wins = vim.tbl_filter(
    function(win_id) return vim.fn.getwininfo(win_id)[1].quickfix == 1 end,
    vim.api.nvim_tabpage_list_wins(0)
  )
  local command = #quickfix_wins == 0 and "copen" or "cclose"
  vim.cmd(command)
end

setmetatable(M, {
  __call = function(m, ...) return m.option(...) end,
})

return M
