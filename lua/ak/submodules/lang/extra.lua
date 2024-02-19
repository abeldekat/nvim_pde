local Util = require("ak.util")
local add = vim.cmd.packadd
local later = Util.defer.later

local function markdown_install()
  -- markdown_preview
  add("markdown-preview.nvim")
  vim.fn["mkdp#util#install_sync"]("v:false") -- not async

  -- peek
  vim.cmd("lcd " .. Util.submodules.plugin_path("peek.nvim", "lang"))
  vim.cmd("!deno task --quiet build:fast")
  vim.cmd("lcd -")
end

local function markdown()
  Util.defer.on_events(function()
    later(function()
      add("markdown-preview.nvim")
      require("ak.config.lang.markdown.markdown_preview")
      add("peek.nvim")
      require("ak.config.lang.markdown.peek")
      add("headlines.nvim")
      require("ak.config.lang.markdown.headlines")
    end)
  end, "FileType", "markdown")
end

local function python()
  Util.defer.on_events(function()
    Util.defer.on_keys(function()
      add("venv-selector.nvim")
      require("ak.config.lang.python.venv_selector")
    end, "<leader>cv", "Venv selector")
  end, "FileType", "python")
end

local function sql()
  Util.defer.on_events(function()
    Util.defer.on_keys(function()
      add("vim-dadbod")
      add("vim-dadbod-completion")
      require("ak.config.lang.sql.dadbod")
    end, "<leader>md", "Load dadbod")
  end, "FileType", "sql")
end

local function langs()
  if Util.submodules.is_provisioning() then
    Util.submodules.print_provision("extra")
    return { markdown_install }
  end
  return {
    markdown,
    python,
    sql,
  }
end

for _, lang in ipairs(langs()) do
  lang()
end
