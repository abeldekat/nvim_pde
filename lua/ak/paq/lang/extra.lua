local Util = require("ak.util")

local M = {}

local markdown = {
  spec = {
    { "toppair/peek.nvim", build = "deno task --quiet build:fast", opt = true },
    {
      "iamcco/markdown-preview.nvim",
      build = function()
        vim.cmd.packadd("markdown-preview.nvim")
        vim.fn["mkdp#util#install"]()
      end,
      opt = true,
    },
    { "lukas-reineke/headlines.nvim", opt = true },
  },
  setup = function()
    Util.defer.on_events(function()
      vim.cmd.packadd("headlines.nvim")
      require("ak.config.lang.markdown.headlines")
      Util.defer.on_keys(function()
        vim.cmd.packadd("markdown-preview.nvim")
        require("ak.config.lang.markdown.markdown_preview")
      end, "<leader>cp", "Markdown preview")
      Util.defer.on_keys(function()
        vim.cmd.packadd("peek.nvim")
        require("ak.config.lang.markdown.peek")
      end, "<leader>ck", "Peek preview")
    end, "FileType", "markdown")
  end,
}

local python = {
  spec = {
    { "linux-cultist/venv-selector.nvim", opt = true },
  },
  setup = function()
    Util.defer.on_events(function()
      Util.defer.on_keys(function()
        vim.cmd.packadd("venv_selector.nvim")
        require("ak.config.lang.python.venv_selector")
      end, "<leader>cv", "Venv selector")
    end, "FileType", "python")
  end,
}

local sql = {
  spec = {
    { "kristijanhusak/vim-dadbod-completion", opt = true },
    { "tpope/vim-dadbod", opt = true },
  },
  setup = function()
    Util.defer.on_events(function()
      Util.defer.on_keys(function()
        vim.cmd.packadd("vim-dadbod-completion")
        vim.cmd.packadd("vim-dadbod")
        require("ak.config.lang.sql.dadbod") -- keys
      end, "<leader>md", "Load dadbod")
    end, "FileType", "sql")
  end,
}

local langs = {
  markdown,
  python,
  sql,
}

function M.spec()
  local result = {}
  for _, lang in ipairs(langs) do
    result = vim.list_extend(result, lang.spec)
  end
  return result
end

function M.setup()
  for _, lang in ipairs(langs) do
    lang.setup()
  end
end

return M
