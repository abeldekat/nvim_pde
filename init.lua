local Util = require("ak.util") -- shared code

local function setup_performance()
  for _, disable in ipairs({ "gzip", "tarPlugin", "tohtml", "tutor", "zipPlugin" }) do
    vim.g["loaded_" .. disable] = 0
  end
  -- NOTE: No performance gain from disabling netrw: netrwPlugin
  -- The plugin is needed to download spell files.
end

---@diagnostic disable:assign-type-mismatch
local function clone()
  local has_cloned = false
  local path_package = vim.fn.stdpath("data") .. "/site/"
  local mini_path = path_package .. "pack/deps/start/mini.nvim"

  if not vim.uv.fs_stat(mini_path) then
    vim.cmd('echo "Installing `mini.nvim`" | redraw')
    local clone_cmd = { "git", "clone", "--filter=blob:none", "https://github.com/echasnovski/mini.nvim", mini_path }
    vim.fn.system(clone_cmd)
    vim.cmd("packadd mini.nvim | helptags ALL")
    vim.cmd('echo "Installed `mini.nvim`" | redraw')
    has_cloned = true
  end

  return has_cloned, path_package
end

setup_performance()
local is_initial_install, path_package = clone()

local MiniDeps = require("mini.deps")
MiniDeps.setup({ path = { package = path_package } }) -- see the plugin folder
if not is_initial_install then return end

--          ╭─────────────────────────────────────────────────────────╮
--          │  On initial install, the install should be reproducible │
--          │              Last step in the later chain:              │
--          │  Restore all plugins to the versions in mini-deps-snap  │
--          ╰─────────────────────────────────────────────────────────╯
vim.api.nvim_create_autocmd("UIEnter", { -- reboot after initial install
  group = vim.api.nvim_create_augroup("ak_init", {}),
  callback = function()
    MiniDeps.later(function()
      Util.deps.load_registered()
      vim.cmd("DepsSnapLoad")
    end)
  end,
})
