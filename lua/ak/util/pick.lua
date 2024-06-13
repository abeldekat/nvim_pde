--          ╭─────────────────────────────────────────────────────────╮
--          │      Picker functionality used in multiple places       │
--          ╰─────────────────────────────────────────────────────────╯

-- TODO: Solve mini-hipatterns telescope dependency

---@class Picker
---@field find_files fun()
---@field live_grep fun()
---@field keymaps fun()
---@field oldfiles fun()
---@field lsp_definitions fun()
---@field lsp_references fun()
---@field lsp_implementations fun()
---@field lsp_type_definitions fun()
---@field colors fun()

local function no_picker(msg) vim.notify("No picker for " .. msg) end

---@type Picker
local No_op = {
  find_files = function() no_picker("find_files") end,
  live_grep = function() no_picker("live_grep") end,
  keymaps = function() no_picker("keymaps") end,
  oldfiles = function() no_picker("oldfiles") end,
  lsp_definitions = function() no_picker("lsp_definitions") end,
  lsp_references = function() no_picker("lsp_references") end,
  lsp_implementations = function() no_picker("lsp_implementations") end,
  lsp_type_definitions = function() no_picker("lsp_type_definitions") end,
  colors = function() no_picker("colors") end,
}

local picker = No_op

---@class ak.util.pick
local M = {}
M.use_picker = function(new_picker) picker = new_picker end
M.find_files = function() picker.find_files() end
M.live_grep = function() picker.live_grep() end
M.keymaps = function() picker.keymaps() end
M.oldfiles = function() picker.oldfiles() end
M.lsp_definitions = function() picker.lsp_definitions() end
M.lsp_references = function() picker.lsp_references() end
M.lsp_implementations = function() picker.lsp_implementations() end
M.lsp_type_definitions = function() picker.lsp_type_definitions() end
M.colors = function() picker.colors() end
return M
