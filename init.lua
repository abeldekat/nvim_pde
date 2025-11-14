-- TODO: Check older keymaps, options and autocommands
-- TODO: Treesitter indentexpression
local function clone()
  local has_cloned = false
  local path_package = vim.fn.stdpath("data") .. "/site/"
  local mini_path = path_package .. "pack/deps/start/mini.nvim"

  if not vim.uv.fs_stat(mini_path) then
    vim.cmd('echo "Installing `mini.nvim`" | redraw')
    local origin = "https://github.com/nvim-mini/mini.nvim"
    local clone_cmd = { "git", "clone", "--filter=blob:none", origin, mini_path }

    vim.fn.system(clone_cmd)
    vim.cmd("packadd mini.nvim | helptags ALL")
    vim.cmd('echo "Installed `mini.nvim`" | redraw')
    has_cloned = true
  end
  return has_cloned, path_package
end

-- TODO: Not in MiniMax?
-- NOTE: No performance gain from disabling netrw: netrwPlugin.
-- NOTE: ToHtml is lazy loaded....
for _, disable in ipairs({ "gzip", "tarPlugin", "tohtml", "tutor", "zipPlugin" }) do
  vim.g["loaded_" .. disable] = 0
end

-- TODO: Is path_package necessary?
local is_initial_install, path_package = clone()
require("mini.deps").setup({ path = { package = path_package } })

-- Define config table to be able to pass data between scripts
_G.Config = {}

local gr = vim.api.nvim_create_augroup("custom-config", {})
_G.Config.new_autocmd = function(event, pattern, callback, desc)
  local opts = { group = gr, pattern = pattern, callback = callback, desc = desc }
  vim.api.nvim_create_autocmd(event, opts)
end
_G.Config.now_if_args = vim.fn.argc(-1) > 0 and MiniDeps.now or MiniDeps.later

if is_initial_install then
  _G.Config.new_autocmd("UIEnter", nil, function()
    MiniDeps.later(function()
      require("akmini.deps_deferred").load_registered()
      vim.cmd("DepsSnapLoad")
    end)
  end, "Restore all plugins to the versions in mini-deps-snap on first install")
end
