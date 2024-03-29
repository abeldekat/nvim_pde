--          ╭─────────────────────────────────────────────────────────╮
--          │                       Grappleline                       │
--          ╰─────────────────────────────────────────────────────────╯
local M = {}
local Grappleline = require("grappleline")

local function extended(on_update)
  Grappleline.setup({
    override_scope_names = { git = "", git_branch = "dev" },
    on_update = on_update,
  })
end

local function short(on_update)
  Grappleline.setup({
    override_scope_names = { git = "", git_branch = "dev" },
    formatter = "short",
    on_update = on_update,
  })
end

local function override(on_update)
  Grappleline.setup({
    formatter_opts = {
      extended = { -- customize the extended builtin
        indicators = { " j ", " k ", " l ", " h " },
        active_indicators = { "<j>", "<k>", "<l>", "<h>" },
        empty_slot = " · ",
      },
    },
    on_update = on_update,
  })
end

local function extended_shortened(on_update)
  Grappleline.setup({
    override_scope_names = { git = "", git_branch = "dev" },
    formatter_opts = {
      extended = { -- remove all spaces....
        indicators = { "1", "2", "3", "4" },
        empty_slot = "·",
        more_marks_indicator = "…", -- horizontal elipsis. Disable with empty string
        more_marks_active_indicator = "[…]", -- Disable with empty string
      },
    },
    on_update = on_update,
  })
end

local function custom(on_update)
  Grappleline.setup({
    custom_formatter = Grappleline.gen_formatter(
      ---@param data GrapplelineData
      ---@return string
      function(data)
        return string.format(
          "%s%s%s",
          "➡️ ",
          data.scope_name and string.format("%s ", data.scope_name) or "",
          data.buffer_idx and string.format("%d", data.buffer_idx) or "-"
        )
      end
    ),
    on_update = on_update,
  })
end

local function grapple(on_update)
  Grappleline.setup({
    -- formatter = "grapple_name_or_index",
    formatter = "grapple", -- the statusline function in grapple.nvim
    on_update = on_update,
  })
end

-- Completely hide the line when there are no tags in some predefined scopes
local function very_conditional(on_update)
  local Grapple = require("grapple")
  local scopes = { "git", "git_branch" } -- assuming no override_scope_names

  local function nr_of_tags()
    local result = 0
    for _, scopename in ipairs(scopes) do
      result = result + #Grapple.tags({ scope = scopename })
    end
    return result
  end

  ---@param data GrapplelineData
  ---@param builtin function
  local function conditional_formatter(data, builtin)
    -- the current scope has tags:
    if data.number_of_tags > 0 then return builtin(data) end
    -- there are tags in all scopes of interest:
    if nr_of_tags() > 0 then return builtin(data) end
    return "" -- no tags, don't show anything
  end

  local gen_formatter_org = Grappleline.gen_formatter
  ---@diagnostic disable-next-line: duplicate-set-field
  Grappleline.gen_formatter = function(builtin) -- capture the builtin formatter
    return gen_formatter_org(function(data) --
      return conditional_formatter(data, builtin) -- closure on builtin!
    end)
  end
  Grappleline.setup({ -- formatter = "extended" -- or any other builtin...
    on_update = on_update,
  })
end

local flavors = {
  extended = extended,
  short = short,
  override = override,
  extended_shortened = extended_shortened,
  custom = custom,
  grapple = grapple,
  very_conditional = very_conditional,
}

---@param on_update function
function M.setup(on_update)
  --
  flavors.very_conditional(on_update)
end

return M
