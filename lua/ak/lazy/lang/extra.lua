local result = {}

local function markdown()
  return {
    {
      "iamcco/markdown-preview.nvim",
      cmd = { "MarkdownPreviewToggle" },
      build = function()
        vim.fn["mkdp#util#install"]()
      end,
      keys = { "<leader>cp", desc = "Markdown preview" },
      config = function()
        require("ak.config.lang.markdown.markdown_preview")
      end,
    },
    {
      "toppair/peek.nvim",
      build = "deno task --quiet build:fast",
      keys = { "<leader>ck", desc = "Peek" },
      config = function()
        require("ak.config.lang.markdown.peek")
      end,
    },
    {
      "lukas-reineke/headlines.nvim",
      ft = { "markdown" }, -- ft = { "markdown", "norg", "rmd", "org" },
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
      keys = "<leader>cv",
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
      keys = "<leader>md",
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
