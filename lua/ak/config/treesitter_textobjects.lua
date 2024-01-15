--          ╭─────────────────────────────────────────────────────────╮
--          │treesitter textobjects: uses k for block, b is preserved │
--          ╰─────────────────────────────────────────────────────────╯

-- When in diff mode, we want to use the default
-- vim text objects c & C instead of the treesitter ones.
local move = require("nvim-treesitter.textobjects.move") ---@type table<string,fun(...)>
local configs = require("nvim-treesitter.configs")
for name, fn in pairs(move) do
  if name:find("goto") == 1 then
    move[name] = function(q, ...)
      if vim.wo.diff then
        local config = configs.get_module("textobjects.move")[name] ---@type table<string,string>
        for key, query in pairs(config or {}) do
          if q == query and key:find("[%]%[][cC]") then
            vim.cmd("normal! " .. key)
            return
          end
        end
      end
      return fn(q, ...)
    end
  end
end
