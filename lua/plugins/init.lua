local Util = require("util")

local did_init = false

-- local function no_lazy_loading()
--   local Spec = require("lazy.core.plugin").Spec
--   local add_orig = Spec.add
--
--   ---@diagnostic disable-next-line: duplicate-set-field
--   Spec.add = function(_, plugin, results)
--     local result = add_orig(_, plugin, results)
--     result["lazy"] = false
--     return result
--   end
-- end

---@param name "autocmds" | "options" | "keymaps"
local function load(name)
  local function _load(mod)
    if require("lazy.core.cache").find(mod)[1] then
      Util.try(function()
        require(mod)
      end, { msg = "Failed loading " .. mod })
    end
  end
  _load("config." .. name)

  if vim.bo.filetype == "lazy" then
    -- HACK: LazyVim may have overwritten options of the Lazy ui, so reset this here
    vim.cmd([[do VimResized]])
  end
end

------------------------------------------------------------------------------
-- LazyVim: plugins.init, require("lazyvim.config").init()
------------------------------------------------------------------------------
local function on_first_spec_imported()
  if did_init then
    return
  end
  did_init = true
  -- no_lazy_loading()

  -- load options here, before lazy init while sourcing plugin modules
  -- this is needed to make sure options will be correctly applied
  -- after installing missing plugins
  load("options")
  Util.plugin.setup()
end

------------------------------------------------------------------------------
-- LazyVim: First plugin to load, require("lazyvim.config").setup(opts)
------------------------------------------------------------------------------
local function on_first_plugin_to_load()
  -- LazyVim: autocmds can be loaded lazily when not opening a file
  require("config.autocmds") -- load immediately, no need to defer
  -- LazyVim: VeryLazy
  require("config.keymaps") --  load immediately, no need to defer

  local group = vim.api.nvim_create_augroup("AbelDeKat", { clear = true })
  vim.api.nvim_create_autocmd("User", {
    group = group,
    pattern = "VeryLazy",
    callback = function()
      Util.format.setup()
      Util.root.setup()
    end,
  })

  Util.try(function()
    local colorscheme = require("misc.color").color
    if type(colorscheme) == "function" then
      colorscheme()
    else
      vim.cmd.colorscheme(colorscheme)
    end
  end, {
    msg = "Could not load your colorscheme",
    on_error = function(msg)
      Util.error(msg)
      vim.cmd.colorscheme("habamax")
    end,
  })
end

on_first_spec_imported()
return {
  { "folke/lazy.nvim", version = "*" },

  -- HACK: plenary as placeholder for LazyVim.config.setup....
  --
  --> Plenary has no setup function.
  {
    "nvim-lua/plenary.nvim",
    priority = 10000,
    lazy = false,
    cond = true,
    -- version = "*",
    config = function()
      on_first_plugin_to_load()
    end,
  },
}
