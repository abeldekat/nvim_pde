local dev_patterns = {} -- { "grappleline", "harpoonline" }
local dev_path = "~/projects/lazydev"

---@diagnostic disable:assign-type-mismatch
local function clone(owner, name)
  local url = string.format("%s/%s/%s.git", "https://github.com", owner, name)
  local path = vim.fn.stdpath("data") .. "/lazy/" .. name
  if not vim.uv.fs_stat(path) then
    vim.fn.system({ "git", "clone", "--filter=blob:none", url, "--branch=stable", path })
  end
  return path
end

local function to_spec()
  return {
    require("ak.lazy.start"),
    require("ak.lazy.coding"),
    require("ak.lazy.colors"),
    require("ak.lazy.editor"),
    require("ak.lazy.treesitter"),
    require("ak.lazy.ui"),
    require("ak.lazy.util"),
    require("ak.lazy.lang.formatting"),
    require("ak.lazy.lang.linting"),
    require("ak.lazy.lang.lsp"),
    require("ak.lazy.lang.testing"),
    require("ak.lazy.lang.debugging"),
    require("ak.lazy.lang.extra"),
  }
end

--          ╭─────────────────────────────────────────────────────────╮
--          │                  Default: lazy = true                   │
--          ╰─────────────────────────────────────────────────────────╯
return function(_) -- opts
  -- Note: lazy.nvim removes the packpath...
  local lazypath = clone("folke", "lazy.nvim")
  vim.opt.rtp:prepend(vim.env.LAZY or lazypath)

  require("lazy").setup({
    defaults = { lazy = true, version = false }, -- "*" = latest stable version
    spec = to_spec(),
    dev = { path = dev_path, patterns = dev_patterns },
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
