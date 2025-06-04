local Picker = require("akshared.pick")
local Lazyrc = require("akshared.lazyrc")
local use_hex_and_shorthand = false -- only enable when needed

-- see mini.hipatterns, H.create_default_hl
local hipatterns = require("mini.hipatterns")
local function to_pattern(word) return " " .. word .. ":" end
local function get_highlighters()
  local highlighters = {
    FIX = { pattern = to_pattern("FIX"), group = "MiniHipatternsFixme" },
    FIXME = { pattern = to_pattern("FIXME"), group = "MiniHipatternsFixme" },
    FIXIT = { pattern = to_pattern("FIXIT"), group = "MiniHipatternsFixme" },
    BUG = { pattern = to_pattern("BUG"), group = "MiniHipatternsFixme" },
    ISSUE = { pattern = to_pattern("ISSUE"), group = "MiniHipatternsFixme" },

    HACK = { pattern = to_pattern("HACK"), group = "MiniHipatternsHack" },
    WARN = { pattern = to_pattern("WARN"), group = "MiniHipatternsHack" },
    WARNING = { pattern = to_pattern("WARNING"), group = "MiniHipatternsHack" },
    XXX = { pattern = to_pattern("XXX"), group = "MiniHipatternsHack" },

    TODO = { pattern = to_pattern("TODO"), group = "MiniHipatternsTodo" },

    NOTE = { pattern = to_pattern("NOTE"), group = "MiniHipatternsNote" },
    INFO = { pattern = to_pattern("INFO"), group = "MiniHipatternsNote" },

    -- todo-comments.nvim uses the Identifier highlight:
    PERF = { pattern = to_pattern("PERF"), group = "MiniHipatternsNote" },
    OPTIM = { pattern = to_pattern("OPTIM"), group = "MiniHipatternsNote" },
    PERFORMANCE = { pattern = to_pattern("PERFORMANCE"), group = "MiniHipatternsNote" },
    OPTIMIZE = { pattern = to_pattern("OPTIMIZE"), group = "MiniHipatternsNote" },

    -- todo-comments.nvim uses the Identifier highlight:
    TEST = { pattern = to_pattern("TEST"), group = "MiniHipatternsNote" },
    TESTING = { pattern = to_pattern("TESTING"), group = "MiniHipatternsNote" },
    PASSED = { pattern = to_pattern("PASSED"), group = "MiniHipatternsNote" },
    FAILED = { pattern = to_pattern("FAILED"), group = "MiniHipatternsFixme" },
  }
  if use_hex_and_shorthand then
    highlighters["hex_color"] = hipatterns.gen_highlighter.hex_color()
    highlighters["shorthand"] = {
      pattern = "()#%x%x%x()%f[^%x%w]",
      group = function(_, _, data)
        ---@type string
        local match = data.full_match
        local r, g, b = match:sub(2, 2), match:sub(3, 3), match:sub(4, 4)
        local hex_color = "#" .. r .. r .. g .. g .. b .. b

        return MiniHipatterns.compute_hex_color_group(hex_color, "bg")
      end,
      extmark_opts = { priority = 2000 },
    }
  end
  return highlighters
end

local highlighters = get_highlighters()
local opts = { highlighters = highlighters }
hipatterns.setup(Lazyrc.merge_opts("hipatterns", opts))

-- Todo-comments using mini.hipatterns:
vim.keymap.set(
  "n",
  "<leader>ft",
  function() Picker.todo_comments(highlighters) end,
  { desc = "Todo all", silent = true }
)
vim.keymap.set("n", "<leader>fT", function()
  local function filter(keys)
    local result = {}
    for _, key in ipairs(keys) do
      local config = highlighters[key]
      if config then result[key] = config end
    end
    return result
  end
  Picker.todo_comments(filter({ "TODO", "FIX", "FIXME" }))
end, { desc = "Todo/Fix/Fixme", silent = true })
