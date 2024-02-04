local Util = require("ak.util")

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

local function modules()
  if Util.submodules.is_provisioning() then
    return {
      "ak.submodules.coding", -- provision luasnip
      "ak.submodules.editor", -- provision telescope
      "ak.submodules.treesitter", -- provision parsers
      "ak.submodules.lang.lsp", -- provision mason registry
      "ak.submodules.lang.extra", -- provision markdown
    }
  end
  return {
    "ak.submodules.start",
    "ak.submodules.coding",
    "ak.submodules.editor",
    "ak.submodules.treesitter",
    "ak.submodules.ui",
    "ak.submodules.util",
    "ak.submodules.lang.formatting",
    "ak.submodules.lang.linting",
    "ak.submodules.lang.lsp",
    "ak.submodules.lang.testing",
    "ak.submodules.lang.debugging",
    "ak.submodules.lang.extra",
  }
end

return function(_) -- opts
  setup_performance()

  -- When using submodules, lualine overriding behaves differently,
  -- because both the override and the lualine plugin are in the config folder
  -- See: lualine.utils.loader.lua, function load_theme, line 232
  --
  local lualine_override = vim.fn.stdpath("config") .. "/lualine_themes"
  vim.opt.rtp:append(lualine_override)

  for _, module in ipairs(modules()) do
    require(module)
  end
end
