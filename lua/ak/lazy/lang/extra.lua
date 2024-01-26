local result = {}

local function markdown()
  return {
    {
      "iamcco/markdown-preview.nvim",
      ft = "markdown",
      build = function()
        vim.fn["mkdp#util#install"]()
      end,
      config = function()
        require("ak.config.lang.markdown.markdown_preview")
      end,
    },
    {
      "toppair/peek.nvim",
      ft = "markdown",
      build = "deno task --quiet build:fast",
      config = function()
        require("ak.config.lang.markdown.peek")
      end,
    },
    {
      "lukas-reineke/headlines.nvim",
      ft = "markdown",
      config = function()
        require("ak.config.lang.markdown.headlines")
      end,
    },
  }
end

local function python()
  return {
    {
      "linux-cultist/venv-selector.nvim",
      keys = { { "<leader>cv", desc = "Venv selector", ft = "python" } },
      config = function()
        require("ak.config.lang.python.venv_selector")
      end,
    },
  }
end

local function sql()
  return {
    {
      "tpope/vim-dadbod",
      keys = { { "<leader>md", desc = "Load dadbod", ft = "sql" } },
      dependencies = { "kristijanhusak/vim-dadbod-completion" },
      config = function()
        require("ak.config.lang.sql.dadbod")
      end,
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
