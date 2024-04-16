local use_hex_and_shorthand = false -- only enable when needed

-- see mini.hipatterns, H.create_default_hl
local hipatterns = require("mini.hipatterns")
-- prepend a space, append a colon:
local function to_pattern(word) return " " .. word .. ":" end

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

hipatterns.setup({ highlighters = highlighters })

local has_telescope, _ = pcall(require, "telescope")
if has_telescope then
  --          ╭─────────────────────────────────────────────────────────╮
  --          │              Replacing todo-comments.nvim               │
  --          ╰─────────────────────────────────────────────────────────╯
  local alt_groups = { -- In telescope, without the background:
    MiniHipatternsFixme = "DiagnosticError",
    MiniHipatternsHack = "DiagnosticWarn",
    MiniHipatternsTodo = "DiagnosticInfo",
    MiniHipatternsNote = "DiagnosticHint",
  }
  local todo_comments = {}
  for key, config in pairs(highlighters) do
    if type(config.pattern) == "string" then
      config = vim.tbl_extend("force", config, { group = alt_groups[config.group] })
      todo_comments[key] = config
    end
  end

  local function todo_opts(todos)
    local function search_regex(keywords)
      local pattern = [[\b(KEYWORDS):]]
      return pattern:gsub("KEYWORDS", table.concat(keywords, "|"))
    end

    local opts = {}
    -- stylua: ignore start
    opts.vimgrep_arguments = {
      "rg", "--color=never", "--no-heading", "--with-filename", "--line-number", "--column"
    }
    -- stylua: ignore end
    opts.prompt_title = "Find Todo"
    opts.use_regex = true
    opts.search = search_regex(vim.tbl_keys(todos))
    local entry_maker = require("telescope.make_entry").gen_from_vimgrep(opts)
    opts.entry_maker = function(line)
      local entry_result = entry_maker(line)

      entry_result.display = function(entry)
        local function find_todo()
          for _, hl in pairs(todo_comments) do
            local pattern = hl.pattern:sub(2) -- remove the prepending space
            if entry.text:find(pattern, 1, true) then return hl end
          end
          return todo_comments[1] -- prevent nil
        end
        local todo = find_todo()
        local display = string.format("%s:%s:%s ", entry.filename, entry.lnum, entry.col)
        local text_result = todo.pattern .. " " .. display .. " " .. entry.text
        return text_result, { { { 0, #todo.pattern }, todo.group } }
      end
      return entry_result
    end
    return opts
  end

  vim.keymap.set("n", "<leader>st", function()
    require("telescope.builtin").grep_string(todo_opts(todo_comments)) --
  end, { desc = "Todo", silent = true })
  vim.keymap.set("n", "<leader>sT", function()
    local function filter(keys)
      local result = {}
      for _, key in ipairs(keys) do
        local config = todo_comments[key]
        if config then result[key] = config end
      end
      return result
    end

    require("telescope.builtin").grep_string(todo_opts(filter({ "TODO", "FIX", "FIXME" })))
  end, { desc = "Todo/Fix/Fixme", silent = true })
end
