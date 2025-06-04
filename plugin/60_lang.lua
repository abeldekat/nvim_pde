local DeferredDeps = require("akmini.deps_deferred")
local add, now, later = MiniDeps.add, MiniDeps.now, MiniDeps.later

local use_mason = false
local H = {}

later(function()
  H.base()
  H.testing()
  H.debugging()
  H.markdown()
  H.sql()
  H.latex()
end)

H.base = function()
  add("stevearc/conform.nvim")
  require("ak.lang.formatting")
  add("mfussenegger/nvim-lint")
  require("ak.lang.linting")

  if use_mason then
    add("williamboman/mason.nvim")
    require("mason").setup()
  end

  add("b0o/SchemaStore.nvim")
  add("neovim/nvim-lspconfig")
  require("ak.lang.lsp")

  if vim.fn.argc(-1) == 0 then return end -- dashboard
  local ft = vim.bo.filetype
  if not ft or ({ minifiles = true, netrw = true })[ft] then return end -- explorer

  -- The lsp does not attach when directly opening a file:
  vim.api.nvim_exec_autocmds("FileType", {
    modeline = false,
    pattern = vim.bo.filetype,
  })
end

-- NOTE: Not using testing at the moment.
H.testing = function()
  local test_spec = {
    source = "nvim-neotest/neotest",
    depends = { "nvim-neotest/nvim-nio" },
  }
  DeferredDeps.register(test_spec)
  local function load_testing()
    add(test_spec)
    require("ak.lang.testing")
    vim.notify("Loaded neotest", vim.log.levels.INFO)
  end
  DeferredDeps.on_keys(function() now(load_testing) end, "<leader>tL", "Load neotest")
end

-- NOTE: Not using dap at the moment. Consider nvim-dap-view
H.debugging = function()
  local dap_spec = {
    source = "mfussenegger/nvim-dap",
    depends = {
      "nvim-neotest/nvim-nio", -- dependency for dap ui
      "rcarriga/nvim-dap-ui",
      "theHamsta/nvim-dap-virtual-text",
      "jbyuki/one-small-step-for-vimkind", -- lua
    },
  }
  DeferredDeps.register(dap_spec)
  local function load_dap()
    add(dap_spec)
    require("ak.lang.debugging")
    vim.notify("Loaded nvim-dap", vim.log.levels.INFO)
  end
  DeferredDeps.on_keys(function() now(load_dap) end, "<leader>dL", "Load dap")
end

H.markdown = function()
  local function add_md(source, to_require, hook)
    if hook then source = { source = source, hooks = { post_install = hook, post_checkout = hook } } end

    DeferredDeps.register(source)
    local function load()
      add(source)
      require("ak.lang." .. to_require)
    end
    DeferredDeps.on_event(function() later(load) end, "FileType", "markdown")
  end

  local function build_peek(params)
    later(function()
      vim.cmd("lcd " .. params.path)
      vim.cmd("!deno task --quiet build:fast")
      vim.cmd("lcd -")
    end)
  end
  add_md("toppair/peek.nvim", "peek", build_peek)

  add_md("MeanderingProgrammer/render-markdown.nvim", "render_markdown")
end

H.sql = function()
  local spec = { source = "tpope/vim-dadbod" }

  DeferredDeps.register(spec)
  local function load_dadbod()
    add(spec)
    require("ak.lang.dadbod")
    vim.notify("Loaded dadbod", vim.log.levels.INFO)
  end
  DeferredDeps.on_event(function()
    DeferredDeps.on_keys(function() now(load_dadbod) end, "<leader>od", "Load dadbod")
  end, "FileType", "sql")
end

H.latex = function() -- not "lazy" loaded as per plugin requirements
  require("ak.lang.vimtex") -- only vimscript variables
  add("lervag/vimtex")
end
