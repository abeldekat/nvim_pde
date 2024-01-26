local Util = require("ak.util")

local did_init = false

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
    vim.cmd([[do VimResized]])
  end
end

local function on_first_spec_imported()
  if did_init then
    return
  end
  did_init = true

  load("options")
  load("autocmds")
  load("keymaps")
end

local function on_first_plugin_to_load()
  vim.keymap.set("n", "<leader>l", "<cmd>Lazy<cr>", { desc = "Lazy", silent = true })

  Util.try(function()
    vim.cmd.colorscheme(require("ak.color").color)
  end, {
    msg = "Could not load your colorscheme",
    on_error = function(msg)
      Util.error(msg)
    end,
  })
end

on_first_spec_imported()
return {
  { "folke/lazy.nvim", version = "*" },

  -- Plenary as placeholder for:
  -- on_first_spec_imported (lazy spec phase)
  -- on_first_plugin_to_load (lazy start phase)
  --
  -- Benefit: No priorities needed on the colorschemes
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
