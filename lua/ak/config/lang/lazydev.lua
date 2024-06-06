---@diagnostic disable: duplicate-set-field

-- If patch_active == true when staring Neovim then:
-- Each workspace has the initial settings + completions for current buffer
-- 1. Completions can be added on the fly for subsequent buffers
-- 2. Or: Deactive the patch. Some buffers might not be attached to Lazydev. See 1.

-- Measurements with this config, Neovim in one tmux pane:
-- no arguments: +/- 20M ( 453 -> 470 )
-- init.lua(no plugin requirements): +/- 210M ( 463 -> 675)
-- lua/ak/config/editor/telescope(large plugin): +/- 320M ( 465 -> 780 )
-- open all files in ak/config: +- 1400M (480 -> 1.900). Lsp processes +/- 2400 files...

local Lazydev = require("lazydev")
local Workspace = require("lazydev.workspace")
local Buf = require("lazydev.buf")
local updated_workspaces = {}

-- Restrict lazydev to one initial update per workspace
local patch_active = true

local function apply_patch()
  local function ws_key(ws) return ws.client_id .. ws.root end

  local ws_update = Workspace.update
  Workspace.update = function(self)
    updated_workspaces[ws_key(self)] = true -- remember ws passed initial update
    return ws_update(self)
  end

  local ws_on_attach = Buf.on_attach
  Buf.on_attach = function(client, buf)
    if patch_active then -- return early if ws has been updated
      local ws = Workspace.find({ buf = buf })
      if ws and updated_workspaces[ws_key(ws)] then
        return --
      end
    end
    ws_on_attach(client, buf)
  end
end

local function ensure_lazydev_attached()
  local bufnr = vim.api.nvim_get_current_buf()
  local clients = vim.lsp.get_clients({ bufnr = bufnr, name = "lua_ls" })
  if clients and #clients == 1 and not Buf.attached[bufnr] then
    Buf.on_attach(clients[1], bufnr) -- Attach to lazydev as well
  end
end

-- Keep setting patch_active. Ensure lazydev on current buffer
local function fetch_once()
  local patch_active_org = patch_active
  patch_active = false
  ensure_lazydev_attached()
  patch_active = patch_active_org
end

-- Toggle setting patch_active. Ensure lazydev on current buffer
local function toggle_patch()
  patch_active = not patch_active
  vim.notify(patch_active and "Lazydev patched" or "Lazydev active")
  if not patch_active then ensure_lazydev_attached() end
end

vim.keymap.set("n", "<leader>mz", fetch_once, { desc = "Attach lazydev", silent = true })
vim.keymap.set("n", "<leader>mZ", toggle_patch, { desc = "Toggle lazydev" })
apply_patch()

Lazydev.setup({ -- mv .luarc.jsonc to .luarc.jsonc.bak  Or use vim rc.
  -- debug = true,
  integrations = { cmp = false },
  library = { { path = "luvit-meta/library", words = { "vim%.uv" } } },
})
