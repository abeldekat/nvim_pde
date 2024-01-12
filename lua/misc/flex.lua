local function spec(opts)
  return {
    "abeldekat/lazyflex.nvim",
    version = "*",
    import = "lazyflex.hook",
    opts = function()
      if not opts.use then
        return nil -- lazyflex opts-out early
      end

      local settings = { enabled = true }
      local presets = {}
      local col = require("misc.flex_collection")
      return {
        filter_import = { enabled = false, kw = {} },
        lazyvim = { settings = settings, presets = presets },
        user = {
          get_preset_keywords = col.get_preset_keywords,
          change_settings = col.change_settings,
          settings = settings,
          presets = presets,
        },
        kw_always_enable = { require("misc.color").color, "har", "plen" },
        enable_match = true,
        override_kw = {},
        kw = {},
      }
    end,
  }
end

return function(opts)
  return spec(opts)
end
