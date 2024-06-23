--          ╭─────────────────────────────────────────────────────────╮
--          │      Picker functionality used in multiple places       │
--          ╰─────────────────────────────────────────────────────────╯

---@class Picker
---@field keymaps fun()
---@field lsp_definitions fun()
---@field lsp_references fun()
---@field lsp_implementations fun()
---@field lsp_type_definitions fun()
---@field colors fun()
---@field todo_comments fun(patterns: table)

local function no_picker(msg) vim.notify("No picker for " .. msg) end

---@type Picker
local No_op = {
  keymaps = function() no_picker("keymaps") end,
  lsp_definitions = function() no_picker("lsp_definitions") end,
  lsp_references = function() no_picker("lsp_references") end,
  lsp_implementations = function() no_picker("lsp_implementations") end,
  lsp_type_definitions = function() no_picker("lsp_type_definitions") end,
  colors = function() no_picker("colors") end,
  todo_comments = function(_) no_picker("todo_comments") end,
}

local picker = No_op

---@class ak.util.pick
local M = {}
M.use_picker = function(new_picker) picker = new_picker end
M.keymaps = function() picker.keymaps() end
M.lsp_definitions = function() picker.lsp_definitions() end
M.lsp_references = function() picker.lsp_references() end
M.lsp_implementations = function() picker.lsp_implementations() end
M.lsp_type_definitions = function() picker.lsp_type_definitions() end
M.colors = function() picker.colors() end
-- patterns argument: See mini.hipatterns, config, highlighters
M.todo_comments = function(patterns) picker.todo_comments(patterns) end
return M
