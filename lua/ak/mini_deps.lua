local Util = require("ak.util")

local function setup_performance()
  for _, disable in ipairs({ "gzip", "netrwPlugin", "tarPlugin", "tohtml", "tutor", "zipPlugin" }) do
    vim.g["loaded_" .. disable] = 0
  end
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

local modules = {
  "ak.deps.start",
  "ak.deps.colors",
  "ak.deps.treesitter",
  "ak.deps.coding",
  "ak.deps.editor",
  "ak.deps.ui",
  "ak.deps.util",
  "ak.deps.lang.formatting",
  "ak.deps.lang.linting",
  "ak.deps.lang.lsp",
  "ak.deps.lang.testing",
  "ak.deps.lang.debugging",
  "ak.deps.lang.extra",
}

return function(_) -- opts
  setup_performance()
  local is_initial_install, path_package = clone()

  --          ╭─────────────────────────────────────────────────────────╮
  --          │  Patch MiniDeps to always include optional plugins on   │
  --          │                 the following commands:                 │
  --          │    DepsClean, DepsUpdate, DepsSnapLoad, DepsSnapSave    │
  --          ╰─────────────────────────────────────────────────────────╯
  Util.deps.patch()

  local MiniDepsPatched = require("mini.deps")
  MiniDepsPatched.setup({ path = { package = path_package } })
  for _, module in ipairs(modules) do
    require(module)
  end
  if is_initial_install then
    --          ╭─────────────────────────────────────────────────────────╮
    --          │On an initial install, the install should be reproducible│
    --          │              Last step in the later chain:              │
    --          │  Restore all plugins to the versions in mini-deps-snap  │
    --          ╰─────────────────────────────────────────────────────────╯
    MiniDepsPatched.later(function() vim.cmd("DepsSnapLoad") end) --
  end
end
