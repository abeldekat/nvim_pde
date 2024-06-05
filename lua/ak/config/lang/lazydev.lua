---@diagnostic disable: duplicate-set-field

local Workspace = require("lazydev.workspace")
local Buf = require("lazydev.buf")
local updated_workspaces = {}

-- Restrict lazydev to one initial update per workspace
local patch_active = true

local function ws_key(ws) return ws.client_id .. ws.root end

-- If the workspace has properly been setup(first update),
-- don't attach to other buffers in the same workspace
local function apply_patch()
  local ws_update = Workspace.update
  Workspace.update = function(self)
    local result = ws_update(self)
    updated_workspaces[ws_key(self)] = true -- remember ws initial update
    return result
  end

  local ws_on_attach = Buf.on_attach
  Buf.on_attach = function(client, buf)
    local ws = Workspace.get(client.id, Workspace.get_root(client, buf)) --
    if patch_active and updated_workspaces[ws_key(ws)] then return end
    ws_on_attach(client, buf)
  end
end

local function attach_lazydev_to_buffer()
  local bufnr = vim.api.nvim_get_current_buf()
  local clients = vim.lsp.get_clients({ bufnr = bufnr, name = "lua_ls" })
  if #clients ~= 1 then return end

  -- lua_ls client attached to buf,
  -- make sure it's also attached to lazydev:
  if not Buf.attached[bufnr] then Buf.on_attach(clients[1], bufnr) end
end

local function toggle_patch()
  patch_active = not patch_active
  vim.notify(patch_active and "Lazydev patched" or "Lazydev active")
  if not patch_active then attach_lazydev_to_buffer() end
end

vim.keymap.set("n", "<leader>cz", toggle_patch, { desc = "Toggle lazydev", silent = true })
vim.keymap.set("n", "<leader>cZ", attach_lazydev_to_buffer, { desc = "Attach to lazydev" })
apply_patch()
require("lazydev").setup({ -- mv .luarc.jsonc to .luarc.jsonc.bak
  cmp = false,
  debug = true,
  library = { { path = "luvit-meta/library", words = { "vim%.uv" } } },
})
