local Util = require("ak.util")
local dev_patterns = {}
local dev_path = "~/projects/lazydev"

---@diagnostic disable:assign-type-mismatch
local function clone(owner, name)
  local url = string.format("%s/%s/%s.git", "https://github.com", owner, name)
  local path = vim.fn.stdpath("data") .. "/lazy/" .. name
  if not vim.loop.fs_stat(path) then
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
    --
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
return function(extraspec, _)
  local lazypath = clone("folke", "lazy.nvim")
  vim.opt.rtp:prepend(vim.env.LAZY or lazypath)

  -- When using submodules, lualine overriding behaves differently,
  -- because both the override and the lualine plugin are in the config folder
  -- See: lualine.utils.loader.lua, function load_theme, line 232
  --
  local lualine_override = vim.fn.stdpath("config") .. "/lualine_themes"

  -- flash: Defined in coding, also used in editor, for telescope
  -- eyeliner: Defined in coding, also used in treesitter, for textobjects
  -- trouble: Defined in editor, also used in lang.testing, for neotest
  -- nvim-dap-python: Defined in dap, also used in lang.python, for venv-selector
  Util.register_referenced({ "flash.nvim", "eyeliner.nvim", "trouble.nvim", "nvim-dap-python" })
  local spec = to_spec()

  require("lazy").setup({
    defaults = { lazy = true, version = false }, -- "*" = latest stable version
    spec = extraspec and vim.list_extend(spec, extraspec) or spec,
    dev = { path = dev_path, patterns = dev_patterns },
    install = { colorscheme = { "tokyonight", "habamax" } },
    checker = { enabled = false },
    change_detection = { enabled = false },
    performance = {
      rtp = { -- "matchit", "matchparen",
        disabled_plugins = { "gzip", "netrwPlugin", "tarPlugin", "tohtml", "tutor", "zipPlugin" },
        paths = { lualine_override },
      },
    },
  })
end
