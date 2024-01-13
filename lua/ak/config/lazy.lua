---@diagnostic disable:assign-type-mismatch
local function clone(owner, name)
  local url = string.format("%s/%s/%s.git", "https://github.com", owner, name)
  local path = vim.fn.stdpath("data") .. "/lazy/" .. name
  if not vim.loop.fs_stat(path) then
    vim.fn.system({ "git", "clone", "--filter=blob:none", url, "--branch=stable", path })
  end
  return path
end

return function(extraspec, opts)
  local _ = opts.flex and { clone("abeldekat", "lazyflex.nvim") } or {}

  local lazypath = clone("folke", "lazy.nvim")
  vim.opt.rtp:prepend(vim.env.LAZY or lazypath)

  local spec = {
    opts.flex or {},
    { import = "ak.plugins" },
    { import = "ak.plugins.coding" },
    { import = "ak.plugins.colorscheme" },
    { import = "ak.plugins.editor" },
    { import = "ak.plugins.ui" },
    { import = "ak.plugins.util" },
    -- langs:   ak.p
    { import = "ak.plugins.formatting" },
    { import = "ak.plugins.linting" },
    { import = "ak.plugins.treesitter" },
    { import = "ak.plugins.lsp" },
    { import = "ak.plugins.test" },
    { import = "ak.plugins.debug" },
    { import = "ak.plugins.langs" },
  }

  require("lazy").setup({
    defaults = { lazy = false, version = false }, -- "*" = latest stable version
    spec = extraspec and vim.list_extend(spec, extraspec) or spec,
    dev = { path = opts.dev_path, patterns = opts.dev_patterns },
    install = { colorscheme = { "tokyonight", "habamax" } },
    checker = { enabled = false },
    change_detection = { enabled = false },
    performance = {
      rtp = { -- "matchit", "matchparen",
        disabled_plugins = { "gzip", "netrwPlugin", "tarPlugin", "tohtml", "tutor", "zipPlugin" },
      },
    },
    debug = opts.debug,
  })
end
