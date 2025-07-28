local function clone()
  local has_cloned = false
  local path_package = vim.fn.stdpath("data") .. "/site/"
  local mini_path = path_package .. "pack/deps/start/mini.nvim"

  if not vim.uv.fs_stat(mini_path) then
    vim.cmd('echo "Installing `mini.nvim`" | redraw')
    local source = "https://github.com/echasnovski/mini.nvim"
    local clone_cmd = { "git", "clone", "--filter=blob:none", source, mini_path }

    vim.fn.system(clone_cmd)
    vim.cmd("packadd mini.nvim | helptags ALL")
    vim.cmd('echo "Installed `mini.nvim`" | redraw')
    has_cloned = true
  end
  return has_cloned, path_package
end

-- NOTE: No performance gain from disabling netrw: netrwPlugin. Is required to download spell files.
-- NOTE: ToHtml is lazy loaded....
for _, disable in ipairs({ "gzip", "tarPlugin", "tohtml", "tutor", "zipPlugin" }) do
  vim.g["loaded_" .. disable] = 0
end
local is_initial_install, path_package = clone()

local MiniDeps = require("mini.deps")
local DepsDeferred = require("akmini.deps_deferred")
MiniDeps.setup({ path = { package = path_package } })
if not is_initial_install then return end

vim.api.nvim_create_autocmd("UIEnter", {
  group = vim.api.nvim_create_augroup("ak_init", {}),
  callback = function()
    MiniDeps.later(function() -- restore all plugins to the versions in mini-deps-snap
      DepsDeferred.load_registered()
      vim.cmd("DepsSnapLoad")
    end)
  end,
})
