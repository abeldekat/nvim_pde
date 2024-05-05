--          ╭─────────────────────────────────────────────────────────╮
--          │                       Harpoonline                       │
--          ╰─────────────────────────────────────────────────────────╯
local M = {}
local Harpoonline = require("harpoonline")

local function default(on_update)
  Harpoonline.setup({
    on_update = on_update,
  })
end

local function short(on_update)
  Harpoonline.setup({
    formatter = "short",
    on_update = on_update,
  })
end

local function shortened_default(on_update)
  Harpoonline.setup({
    formatter_opts = {
      default = { -- remove all spaces...
        inactive = "%s",
        active = "[%s]",
      },
    },
    on_update = on_update,
  })
end

local function custom(on_update)
  Harpoonline.setup({
    ---@param data HarpoonlineData
    ---@param opts HarpoonLineConfig
    ---@return string
    custom_formatter = function(data, opts)
      return string.format(
        "%s%s%s",
        opts.icon .. " ",
        data.list_name and string.format("%s ", data.list_name) or "",
        data.active_idx and string.format("%d", data.active_idx) or "-"
      )
    end,
    on_update = on_update,
  })
end

local function custom_letters(on_update)
  Harpoonline.setup({
    ---@param data HarpoonlineData
    ---@param opts HarpoonLineConfig
    ---@return string
    custom_formatter = function(data, opts)
      local letters = { "j", "k", "l", "h" }
      local idx = data.active_idx
      local slot = 0
      local slots = vim.tbl_map(function(letter)
        slot = slot + 1
        return idx and idx == slot and string.upper(letter) or letter
      end, vim.list_slice(letters, 1, math.min(#letters, #data.items)))

      local name = data.list_name and data.list_name or opts.default_list_name
      local header = string.format("%s%s%s", opts.icon, name == "" and "" or " ", name)
      return header .. " " .. table.concat(slots)
    end,
    on_update = on_update,
  })
end

local flavors = {
  default = default,
  short = short,
  shortened_default = shortened_default,
  custom = custom,
  custom_letters = custom_letters,
}

---@param on_update function
function M.setup(on_update)
  --
  flavors.shortened_default(on_update)
end

return M
