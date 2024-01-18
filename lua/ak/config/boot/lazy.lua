local function to_spec()
  return {
    require("ak.lazy.start"), -- responsible for options, keys, autocmds and colorscheme
    require("ak.lazy.coding"),
    require("ak.lazy.colors"),
    require("ak.lazy.editor"),
    require("ak.lazy.treesitter"),
    require("ak.lazy.ui"),
    require("ak.lazy.util"),
    --
    require("ak.lazy.lang.formatting"),
    require("ak.lazy.lang.linting"),
    require("ak.lazy.lang.lsp"),
    require("ak.lazy.lang.testing"),
    require("ak.lazy.lang.debugging"),
    require("ak.lazy.lang.extra"),
  }
end

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
  local lazypath = clone("folke", "lazy.nvim")
  vim.opt.rtp:prepend(vim.env.LAZY or lazypath)

  local spec = to_spec()
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
  })
end
