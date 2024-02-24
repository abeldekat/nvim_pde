local Util = require("ak.util")
local MiniDeps = require("mini.deps")
local add, now, later = MiniDeps.add, MiniDeps.now, MiniDeps.later
local register = Util.deps.register

---@param source string
---@param to_require string
---@param hook? fun()
local function add_md(source, to_require, hook)
  ---@type string|table
  local _source = source
  if hook then _source = { source = source, hooks = { post_install = hook, post_checkout = hook } } end

  local function load()
    add(_source)
    require("ak.config.lang.markdown." .. to_require)
  end
  register(_source)
  Util.defer.on_events(function() later(load) end, "FileType", "markdown")
end

local function markdown()
  local function buid_markdown_preview()
    later(function() vim.fn["mkdp#util#install"]() end)
  end
  add_md("iamcco/markdown-preview.nvim", "markdown_preview", buid_markdown_preview)

  local function build_peek(params)
    later(function()
      vim.cmd("lcd " .. params.path)
      vim.cmd("!deno task --quiet build:fast")
      vim.cmd("lcd -")
    end)
  end
  add_md("toppair/peek.nvim", "peek", build_peek)

  add_md("lukas-reineke/headlines.nvim", "headlines")
end

local function python()
  local spec = "linux-cultist/venv-selector.nvim"

  local function load()
    add(spec)
    require("ak.config.lang.python.venv_selector")
  end
  register(spec)
  Util.defer.on_events(function()
    Util.defer.on_keys(function() now(load) end, "<leader>cv", "Venv selector")
  end, "FileType", "python")
end

local function sql()
  local spec = { source = "tpope/vim-dadbod", depends = { "kristijanhusak/vim-dadbod-completion" } }

  local function load()
    add(spec)
    require("ak.config.lang.sql.dadbod")
  end
  register(spec)
  Util.defer.on_events(function()
    Util.defer.on_keys(function() now(load) end, "<leader>md", "Load dadbod")
  end, "FileType", "sql")
end

local langs = {
  markdown,
  python,
  sql,
}
for _, lang in ipairs(langs) do
  later(lang)
end
