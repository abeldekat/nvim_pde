--          ╭─────────────────────────────────────────────────────────╮
--          │                    colors mini.nvim:                    │
--          │   - `randomhue` - random background and foreground of   │
--          │          the same hue with medium saturation.           │
--          │  - `minicyan` - cyan and grey main colors with medium   │
--          │            contrast and saturation palette.             │
--          │ - `minischeme` - blue and yellow main colors with high  │
--          │            contrast and saturation palette.             │
--          ╰─────────────────────────────────────────────────────────╯

local Util = require("ak.util")
local Color = require("ak.color")
local MiniDeps = require("mini.deps")
local add, now, later = MiniDeps.add, MiniDeps.now, MiniDeps.later
local register = Util.deps.register
local M = {}

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

local color_selected_groups = {
  colors.one,
  colors.two,
  colors.three,
  colors.four,
}

local function on_each_color(cb)
  for _, group in ipairs(color_selected_groups) do
    for _, spec in ipairs(group()) do
      cb(spec)
    end
  end
end

local function color_apply(color_name, config_name)
  Util.try(function()
    require(config_name)
    vim.cmd.colorscheme(color_name)
  end, {
    msg = "Could not load your colorscheme",
    on_error = function(msg) Util.error(msg) end,
  })
end

-- Only loads the plugin matching the color name set in ak.color
function M.colorscheme()
  local color_name = Color.color
  local info = Util.color.from_color_name(color_name)

  local all_colors = {}
  on_each_color(function(spec)
    table.insert(all_colors, spec)
    if spec.name == info.package_name then
      now(function()
        add(spec)
        color_apply(color_name, info.config_name)
      end)
    else
      later(function() register(spec) end)
    end
  end)

  later(function()
    vim.keymap.set("n", "<leader>uu", function() -- Show all custom colors in telescope
      for _, color in ipairs(all_colors) do
        add(color)
        require(Util.color.from_package_name(color.name).config_name)
      end

      vim.schedule(function() Util.color.telescope_custom_colors() end)
    end, { desc = "Telescope custom colors", silent = true })
  end)
end

return M
