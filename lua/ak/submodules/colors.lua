local Util = require("ak.util")
local Color = require("ak.color")
local add, later = vim.cmd.packadd, Util.defer.later
local M = {}

local colors = {
  one = function()
    return {
      "colors_tokyonight",
      "colors_catppuccin",
      "colors_nightfox",
      "colors_rose-pine",
    }
  end,

  two = function()
    return {
      "colors_onedark",
      "colors_gruvbox",
      "colors_solarized8",
      "colors_solarized-osaka",
      "colors_nano-theme",
    }
  end,

  three = function()
    return {
      "colors_sonokai",
      "colors_monokai-pro",
      "colors_everforest",
      "colors_gruvbox-material",
      "colors_bamboo",
      "colors_melange",
    }
  end,

  four = function()
    return {
      "colors_kanagawa",
      "colors_ayu",
      "colors_edge",
      "colors_leaf",
      "colors_astrotheme",
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
    for _, package_name in ipairs(group()) do
      cb(package_name)
    end
  end
end

local function color_apply(color_name, config_name)
  Util.try(function()
    require(config_name)
    vim.cmd.colorscheme(color_name)
  end, {
    msg = "Could not load your colorscheme",
    on_error = function(msg)
      Util.error(msg)
    end,
  })
end

-- Only loads the plugin matching the color name set in ak.color
function M.colorscheme()
  local all_colors = {}
  local color_name = Color.color
  local info = Util.color.from_color_name(color_name)

  on_each_color(function(package_name)
    table.insert(all_colors, package_name)
    if package_name == info.package_name then
      add(package_name)
      color_apply(color_name, info.config_name)
    end
  end)

  later(function()
    vim.keymap.set("n", "<leader>uu", function() -- Show all custom colors in telescope
      for _, package_name in ipairs(all_colors) do
        add(package_name)
        require(Util.color.from_package_name(package_name).config_name)
      end

      vim.schedule(function()
        Util.color.telescope_custom_colors()
      end)
    end, { desc = "Telescope custom colors", silent = true })
  end)
end

return M
