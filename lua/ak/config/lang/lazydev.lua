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

-- Prevent lazydev from attaching to other buffers in the same workspace.
-- A workspace is guaranteed to be initialized
local use_patch = false

local Lazydev = require("lazydev")
local Workspace = require("lazydev.workspace")
local Buf = require("lazydev.buf")

---@type table<string, boolean>
local workspaces_initialized = {}
---@type table<string, boolean>
local workspaces_is_enabled = {}

local function apply_patch()
  local function ws_key(ws) return ws.client_id .. ws.root end

  local ws_update = Workspace.update
  Workspace.update = function(self)
    workspaces_initialized[ws_key(self)] = true -- remember ws passed initial update
    return ws_update(self)
  end

  local buf_on_attach = Buf.on_attach
  Buf.on_attach = function(client, buf)
    local function ws_is_initialized()
      local ws = Workspace.find({ buf = buf })
      return ws and workspaces_initialized[ws_key(ws)]
    end
    if use_patch and ws_is_initialized() then return end
    buf_on_attach(client, buf)
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
  local patch_active_org = use_patch
  use_patch = false
  ensure_lazydev_attached()
  use_patch = patch_active_org
end

-- Toggle setting patch_active. Ensure lazydev on current buffer
local function toggle_patch()
  use_patch = not use_patch
  vim.notify(use_patch and "Lazydev patched" or "Lazydev active")
  if not use_patch then ensure_lazydev_attached() end
end

vim.keymap.set("n", "<leader>oi", "<cmd>LazyDev<cr>", { desc = "Info lazydev", silent = true })
vim.keymap.set("n", "<leader>oz", fetch_once, { desc = "Attach lazydev", silent = true })
vim.keymap.set("n", "<leader>oZ", toggle_patch, { desc = "Toggle lazydev" })
apply_patch()

-- When using .luarc.jsonc: cp either .luarc.strict or .luarc.nonstrict to .luarc.jsonc
Lazydev.setup({
  -- debug = true,
  enabled = function(root_dir)
    if workspaces_is_enabled[root_dir] == nil then -- test once per workspace:
      local stat = vim.uv.fs_stat(root_dir .. "/.luarc.json") or vim.uv.fs_stat(root_dir .. "/.luarc.jsonc")
      workspaces_is_enabled[root_dir] = not stat and true or false
    end
    local is_enabled_globally = vim.g.lazydev_enabled == nil and true or vim.g.lazydev_enabled
    return workspaces_is_enabled[root_dir] and is_enabled_globally
  end,
  integrations = { cmp = false },

  -- library = { { path = "luvit-meta/library", words = { "vim%.uv" } } },
  -- Loading only uv directly:
  library = { { path = require("lazydev.pkg").get_plugin_path("luvit-meta") .. "/library/uv.lua" } },
})
