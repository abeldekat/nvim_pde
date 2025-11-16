local add, now, later = MiniDeps.add, MiniDeps.now, MiniDeps.later
local now_if_args = _G.Config.now_if_args

now_if_args(function()
  add({
    source = "nvim-treesitter/nvim-treesitter",
    checkout = "main",
    hooks = { post_checkout = function() vim.cmd("TSUpdate") end },
  })
  add({
    source = "nvim-treesitter/nvim-treesitter-textobjects",
    checkout = "main",
  })
  -- NOTE: Only install languages when missing on filetype event
  require("ak.other.treesitter")

  -- TODO:  mini.ai like nvim-treesitter-textobjects.swap. Use < and >

  -- TODO: Inlay hints and dynamic registration. No keymaps on attach?
  add("neovim/nvim-lspconfig")
  require("ak.other.lsp")
end)

later(function()
  add("stevearc/conform.nvim")
  require("ak.other.conform")
  add("rafamadriz/friendly-snippets")
end)

-- Plugins not included in MiniMax ============================================

local DeferredDeps = require("akmini.deps_deferred")

local markdown = function()
  local function add_md(source, to_require, hook)
    if hook then source = { source = source, hooks = { post_install = hook, post_checkout = hook } } end

    DeferredDeps.register(source)
    local function load()
      add(source)
      require("ak.other." .. to_require)
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

local vimtex = function()
  require("ak.other.vimtex") -- only vimscript variables
  add("lervag/vimtex")
end

-- TODO: Add nvim-lint?
-- TODO: Move the definition of keymaps?
-- TODO: Always load markdown?
later(function()
  add("monaqa/dial.nvim")
  require("ak.other.dial")
  add("stevearc/quicker.nvim")
  require("ak.other.quicker")
  add("nvim-treesitter/nvim-treesitter-context")
  require("ak.other.treesitter_context")

  add("b0o/SchemaStore.nvim")
  markdown()
  vimtex()
end)
