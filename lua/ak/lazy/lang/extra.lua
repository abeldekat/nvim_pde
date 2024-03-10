local result = {}

local function on_ft_after_event(filetype, cb, event, pattern)
  local opts = {}
  opts.group = vim.api.nvim_create_augroup("ak_defer", { clear = true })
  if pattern then opts["pattern"] = pattern end
  opts.desc = "ak_defer"
  opts.once = true
  opts.callback = function()
    if vim.bo.filetype == filetype then
      cb() -- call immedialely on event
    else
      vim.api.nvim_create_autocmd("FileType", {
        pattern = filetype, -- call after event on FileType
        once = true,
        callback = function() cb() end,
      })
    end
  end

  vim.api.nvim_create_autocmd(event, opts)
end

local function markdown()
  return {
    {
      "iamcco/markdown-preview.nvim",
      ft = "markdown",
      build = function() vim.fn["mkdp#util#install"]() end,
      config = function() require("ak.config.lang.markdown.markdown_preview") end,
    },
    {
      "toppair/peek.nvim",
      ft = "markdown",
      build = "deno task --quiet build:fast",
      config = function() require("ak.config.lang.markdown.peek") end,
    },
    {
      "lukas-reineke/headlines.nvim",
      ft = vim.fn.has("0.10") == 1 and "markdown" or nil,
      event = vim.fn.has("0.10") == 0
          and function()
            --          ╭─────────────────────────────────────────────────────────╮
            --          │            if treesitter loads on verylazy:             │
            --          │  when opening a markdown file directly, and using ft =  │
            --          │                 markdown in this spec,                  │
            --          │      treesitter is not loaded yet. Without parser,      │
            --          │                headlines fails silently.                │
            --          ╰─────────────────────────────────────────────────────────╯
            on_ft_after_event("markdown", function() require("headlines") end, "User", "VeryLazy")
            return {} -- dummy, event is not controlled by lazy
          end
        or nil,
      config = function() require("ak.config.lang.markdown.headlines") end,
    },
  }
end

local function python()
  return {
    {
      "linux-cultist/venv-selector.nvim",
      keys = { { "<leader>cv", desc = "Venv selector", ft = "python" } },
      config = function() require("ak.config.lang.python.venv_selector") end,
    },
    {
      "wookayin/semshi", -- "numiras/semshi" -- use a maintained fork
      ft = "python",
      build = ":UpdateRemotePlugins",
      init = function() require("ak.config.lang.python.semshi") end,
    },
  }
end

local function sql()
  return {
    {
      "tpope/vim-dadbod",
      keys = { { "<leader>md", desc = "Load dadbod", ft = "sql" } },
      dependencies = { "kristijanhusak/vim-dadbod-completion" },
      config = function() require("ak.config.lang.sql.dadbod") end,
    },
  }
end

local langs = {
  markdown,
  python,
  sql,
}
for _, lang in ipairs(langs) do
  result = vim.list_extend(result, lang())
end
return result
