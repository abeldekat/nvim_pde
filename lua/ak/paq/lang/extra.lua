local M = {}

local function markdown()
  return {
    {
      "iamcco/markdown-preview.nvim",
      build = function()
        vim.fn["mkdp#util#install"]()
      end,
      opt = true,
    },
    { "toppair/peek.nvim", build = "deno task --quiet build:fast", opt = true },
    { "lukas-reineke/headlines.nvim", opt = true },
  }
end

local function python()
  return {
    { "linux-cultist/venv-selector.nvim", opt = true },
  }
end

local function sql()
  return {
    { "kristijanhusak/vim-dadbod-completion", opt = true },
    { "tpope/vim-dadbod", opt = true },
  }
end

function M.spec()
  local result = {}
  local langs = {
    markdown,
    python,
    sql,
  }
  for _, lang in ipairs(langs) do
    result = vim.list_extend(result, lang())
  end
  return result
end

function M.setup()
  -- require("ak.config.lang.markdown.markdown_preview") -- cmd keys
  -- require("ak.config.lang.markdown.peek") -- keys
  -- require("ak.config.lang.markdown.headlines") -- ft
  --
  -- require("ak.config.lang.python.venv_selector") -- keys
  --
  -- require("ak.config.lang.sql.dadbod") -- keys
end

return M
