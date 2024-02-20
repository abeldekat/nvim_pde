local function setup_performance()
  -- tohtml.vim             0.06    0.06
  -- syntax.vim             0.27    0.26 ▏

  -- TODO: More plugins to disable?
  -- disabled_plugins = { "tohtml", "tutor" },
  --
  for _, disable in ipairs({ "gzip", "netrwPlugin", "tarPlugin", "zipPlugin" }) do
    vim.g["loaded_" .. disable] = 0
  end
end

---@diagnostic disable:assign-type-mismatch
local function clone()
  local path_package = vim.fn.stdpath("data") .. "/site/"
  local mini_path = path_package .. "pack/deps/start/mini.nvim"
  if not vim.loop.fs_stat(mini_path) then
    vim.cmd('echo "Installing `mini.nvim`" | redraw')
    local clone_cmd = { "git", "clone", "--filter=blob:none", "https://github.com/echasnovski/mini.nvim", mini_path }
    vim.fn.system(clone_cmd)
    vim.cmd("packadd mini.nvim | helptags ALL")
  end
  return path_package
end

local modules = {
  "ak.deps.start",
  "ak.deps.coding",
  "ak.deps.editor",
  "ak.deps.treesitter",
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
  -- The packpath should not contain ie ~/.config/nvim
  -- that location contains the plugins for ak.submodules
  local to_remove_from_pp = vim.fn.stdpath("config")
  vim.opt.pp:remove(to_remove_from_pp)
  vim.opt.pp:remove(to_remove_from_pp .. "/after")

  setup_performance()
  local path_package = clone()

  require("mini.deps").setup({ path = { package = path_package } })
  for _, module in ipairs(modules) do
    require(module)
  end
end
