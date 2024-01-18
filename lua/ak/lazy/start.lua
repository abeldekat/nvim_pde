local Util = require("ak.util")

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
  _load("ak.config." .. name)

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
  Util.lazy_file.setup()
end

------------------------------------------------------------------------------
-- LazyVim: First plugin to load, require("lazyvim.config").setup(opts)
------------------------------------------------------------------------------
local function on_first_plugin_to_load()
  -- LazyVim: autocmds can be loaded lazily when not opening a file
  load("autocmds") -- load immediately, no need to defer
  -- LazyVim: VeryLazy
  load("keymaps") --  load immediately, no need to defer

  -- lazy
  vim.keymap.set("n", "<leader>l", "<cmd>Lazy<cr>", { desc = "Lazy", silent = true })

  Util.try(function()
    local colorscheme = require("ak.misc.color").color
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

  -- Plenary as placeholder:
  -- on_first_spec_imported (lazy spec phase)
  -- on_first_plugin_to_load (lazy start phase)
  --
  -- Benefit: The colorscheme can be dynamic and does not need a priority
  {
    "nvim-lua/plenary.nvim",
    priority = 10000,
    lazy = false,
    cond = true,
    config = function()
      on_first_plugin_to_load() -- Plenary does not require a setup function
    end,
  },
}
