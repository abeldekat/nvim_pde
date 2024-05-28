--          ╭─────────────────────────────────────────────────────────╮
--          │                    colors mini.nvim:                    │
--          │   - `randomhue` - random background and foreground of   │
--          │          the same hue with medium saturation.           │
--          │  - `minicyan` - cyan and grey main colors with medium   │
--          │            contrast and saturation palette.             │
--          │ - `minischeme` - blue and yellow main colors with high  │
--          │            contrast and saturation palette.             │
--          ╰─────────────────────────────────────────────────────────╯

local M = {}
local Util = require("ak.util")
local Color = require("ak.color")
local MiniDeps = require("mini.deps")
local add, now, later = MiniDeps.add, MiniDeps.now, MiniDeps.later
local register = Util.deps.register

local function hook_nvconfig()
  vim.g.base46_cache = vim.fn.stdpath("data") .. "/nvchad/base46/"
  vim.cmd.packadd("colors_nvconfig")
  require("ak.config.colors.nvconfig").compile()
end
local spec_nvconfig = {
  source = "nvchad/base46", -- v2.5 is the default
  name = "colors_nvconfig",
  hooks = { post_install = hook_nvconfig, post_checkout = hook_nvconfig },
}

local colors = {
  one = function()
    return {
      { source = "catppuccin/nvim", name = "colors_catppuccin" },
      { source = "folke/tokyonight.nvim", name = "colors_tokyonight" },
      { source = "EdenEast/nightfox.nvim", name = "colors_nightfox" },
      { source = "rose-pine/neovim", name = "colors_rose-pine" },
    }
  end,

  two = function()
    return {
      { source = "sainnhe/sonokai", name = "colors_sonokai" },
      { source = "ribru17/bamboo.nvim", name = "colors_bamboo" },
      { source = "sainnhe/everforest", name = "colors_everforest" },
      { source = "sainnhe/gruvbox-material", name = "colors_gruvbox-material" },
      { source = "sainnhe/edge", name = "colors_edge" },
    }
  end,

  three = function()
    return {
      { source = "rebelot/kanagawa.nvim", name = "colors_kanagawa" },
      { source = "ellisonleao/gruvbox.nvim", name = "colors_gruvbox" },
      { source = "Shatur/neovim-ayu", name = "colors_ayu" },
      { source = "navarasu/onedark.nvim", name = "colors_onedark" },
    }
  end,

  four = function()
    return {
      { source = "lifepillar/vim-solarized8", name = "colors_solarized8", checkout = "neovim" },
      { source = "AstroNvim/astrotheme", name = "colors_astrotheme" },
    }
  end,
}

local groups = {
  colors.one,
  colors.two,
  colors.three,
  colors.four,
}

local function register_specs(activate_cb)
  local function on_each_spec(cb)
    for _, group in ipairs(groups) do
      for _, spec in ipairs(group()) do
        cb(spec)
      end
    end
  end

  local specs = {}
  on_each_spec(function(spec)
    table.insert(specs, spec)
    if not activate_cb(spec) then later(function() register(spec) end) end
  end)
  return specs
end

local function add_telescope(specs_to_use)
  vim.keymap.set("n", "<leader>uu", function() -- Show all custom colors in telescope
    for _, spec in ipairs(specs_to_use) do
      add(spec)
      require(Util.color.to_config_name(spec.name))
    end

    vim.schedule(function() Util.color.telescope_custom_colors() end)
  end, { desc = "Telescope custom colors", silent = true })
end

local function activate(color_name, config_name)
  Util.try(function()
    require(config_name)
    vim.cmd.colorscheme(color_name)
  end, {
    msg = "Could not load your colorscheme",
    on_error = function(msg) Util.error(msg) end,
  })
end

function M.colorscheme()
  local active = Util.color.from_color_name(Color.color)
  local specs_to_use = register_specs(function(spec)
    if active.spec_name == spec.name then
      now(function()
        add(spec)
        activate(active.name, active.config_name)
      end)
      return true
    end
    return false -- register only
  end)
  add_telescope(specs_to_use)

  later(function() register(spec_nvconfig) end)
  if active.spec_name == spec_nvconfig.name then
    now(function()
      require("ak.config.colors.nvconfig").setup(function()
        add(spec_nvconfig) -- only add the plugin when selecting a new theme
        return vim.fn.stdpath("data") .. "/site/pack/deps/opt/" .. spec_nvconfig.name .. "/lua/base46/themes"
      end)
    end)
  end
end

return M
