--          ╭─────────────────────────────────────────────────────────╮
--          │        Language components are configurated in:         │
--          │                       treesitter                        │
--          │                         linting                         │
--          │                       formatting                        │
--          │                          mason                          │
--          │                       diagnostics                       │
--          │                           lsp                           │
--          │                     test and debug                      │
--          │                language specific plugins                │
--          ╰─────────────────────────────────────────────────────────╯
local Util = require("ak.util")
local Picker = Util.pick
local H = {}

H.opts = {
  inlay_hints = { auto = false, filter = { "lua" } },
  codeLens = { auto = false, filter = { "lua" } },
}

---@param on_attach fun(client, buffer)
---@param name? string
function H.on_attach(on_attach, name)
  vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(args)
      local buffer = args.buf ---@type number
      local client = vim.lsp.get_client_by_id(args.data.client_id)
      if client and (not name or client.name == name) then on_attach(client, buffer) end
    end,
  })
end

function H.auto_inlay_hints()
  H.on_attach(function(_, buffer)
    -- if client.supports_method("textDocument/inlayHint") then
    if vim.tbl_contains(H.opts.inlay_hints.filter, vim.bo[buffer].filetype) then
      Util.toggle.inlay_hints(buffer, true) --
    end
  end)
end

function H.codelens()
  H.on_attach(function(_, buffer)
    -- if client.supports_method("textDocument/codeLens") then
    if vim.tbl_contains(H.opts.codeLens.filter, vim.bo[buffer].filetype) then
      vim.lsp.codelens.refresh()
      vim.api.nvim_create_autocmd({ "BufEnter", "InsertLeave" }, { --  "CursorHold"
        buffer = buffer,
        callback = vim.lsp.codelens.refresh,
      })
    end
  end)
end

function H.keys(_, buffer) -- client
  local function map(l, r, opts, mode)
    mode = mode or "n"
    opts["buffer"] = buffer
    opts["silent"] = opts.silent ~= false
    vim.keymap.set(mode, l, r, opts)
  end
  map("<leader>cl", "<cmd>LspInfo<cr>", { desc = "Lsp info" })
  map("gd", Picker.lsp_definitions, { desc = "Goto definition" })
  map("gD", vim.lsp.buf.declaration, { desc = "Goto declaration" })
  map("gr", Picker.lsp_references, { desc = "References", nowait = true })
  map("gI", Picker.lsp_implementations, { desc = "Goto implementation" })
  map("gy", Picker.lsp_type_definitions, { desc = "Goto type definition" })
  --   map("K", vim.lsp.buf.hover, { desc = "Hover" }) -- builtin, see lsp-defaults
  map("gK", vim.lsp.buf.signature_help, { desc = "Signature help" })
  map("<c-k>", vim.lsp.buf.signature_help, { desc = "Signature help" }, "i")
  map("<leader>ca", vim.lsp.buf.code_action, { desc = "Code action" }, { "n", "v" })
  map(
    "<leader>cA",
    function() vim.lsp.buf.code_action({ context = { only = { "source" }, diagnostics = {} } }) end,
    { desc = "Source action" }
  )
  map("<leader>cr", vim.lsp.buf.rename, { desc = "Rename" })
  map("<leader>cc", vim.lsp.codelens.run, { desc = "Run Codelens" }, { "n", "v" })
  map("<leader>cC", vim.lsp.codelens.refresh, { desc = "Refresh & Display Codelens" })
end

-- Assumption: .luarc.jsonc takes precendence. Individual values override,
-- arrays are not merged
-- Example: diagnostics global array, "one" in lua_ls settings,
-- and "two" in .luarc.json -> Only a warning on global "one"
-- NOTE: when uncommenting a library block in .luarc.jsonc, the completion
-- becomes available without restarting nvim
function H.lua_ls()
  return {
    handlers = { -- nvim echasnovski
      -- Show only one definition to be usable with `a = function()` style.
      -- Because LuaLS treats both `a` and `function()` as definitions of `a`.
      ["textDocument/definition"] = function(err, result, ctx, config)
        if type(result) == "table" then result = { result[1] } end
        vim.lsp.handlers["textDocument/definition"](err, result, ctx, config)
      end,
    },
    settings = {
      Lua = {
        -- runtime = { version = "LuaJIT" }, -- lazydev or luarc
        codeLens = { enable = true },
        completion = { callSnippet = "Replace" },
        diagnostics = {
          globals = { "vim", "describe", "it", "before_each", "after_each", "MiniIcons", "MiniVisits", "MiniPick" },
        },
        doc = { privateName = { "^_" } },
        hint = { -- default no inlay hints
          enable = true, -- must be true in order to toggle hints on or off
          setType = false,
          paramType = true,
          paramName = "Disable",
          semicolon = "Disable",
          arrayIndex = "Disable",
        },
        workspace = {
          checkThirdParty = false,
          -- library = { -- lazydev or luarc
          --   vim.env.VIMRUNTIME,
          --   "${3rd}/luv/library",
          --   "${3rd}/busted/library",
          -- },
        },
      },
    },
  }
end

function H.jsonls()
  return {
    -- lazy-load schemastore when needed
    on_new_config = function(new_config)
      new_config.settings.json.schemas = new_config.settings.json.schemas or {}
      vim.list_extend(new_config.settings.json.schemas, require("schemastore").json.schemas())
    end,
    settings = {
      json = {
        format = {
          enable = true,
        },
        validate = { enable = true },
      },
    },
  }
end

function H.yamlls()
  return {
    -- Have to add this for yamlls to understand that we support line folding
    capabilities = {
      textDocument = {
        foldingRange = {
          dynamicRegistration = false,
          lineFoldingOnly = true,
        },
      },
    },
    -- lazy-load schemastore when needed
    on_new_config = function(new_config)
      new_config.settings.yaml.schemas =
        vim.tbl_deep_extend("force", new_config.settings.yaml.schemas or {}, require("schemastore").yaml.schemas())
    end,
    settings = {
      redhat = { telemetry = { enabled = false } },
      yaml = {
        keyOrdering = false,
        format = {
          enable = true,
        },
        validate = true,
        schemaStore = {
          -- Must disable built-in schemaStore support to use
          -- schemas from SchemaStore.nvim plugin
          enable = false,
          -- Avoid TypeError: Cannot read properties of undefined (reading 'length')
          url = "",
        },
      },
    },
  }
end

function H.ruff()
  local desc = "Organize imports"
  local opts_code_action = {
    apply = true,
    context = { only = { "source.organizeImports" }, diagnostics = {} },
  }
  local code_action = function() vim.lsp.buf.code_action(opts_code_action) end
  H.on_attach(function(client, buffer)
    vim.keymap.set("n", "<leader>co", code_action, { desc = desc, silent = true, buffer = buffer })
    -- Disable hover in favor of Pyright
    client.server_capabilities.hoverProvider = false
  end, "ruff")
  return {}
end

-- Rust analyzer: Not installed by mason
function H.rust_analyzer(_) -- capabilities setup by rustaceanvim
  -- local lspconfig = require("lspconfig")
  -- local ca = {}
  -- lspconfig.rust_analyzer.setup({
  --   capabilities = vim.tbl_deep_extend("force", {}, capabilities, ca),
  -- })

  local opts = {
    server = {
      on_attach = function(_, bufnr)
        vim.keymap.set(
          "n",
          "<leader>cR",
          function() vim.cmd.RustLsp("codeAction") end,
          { desc = "Code Action", buffer = bufnr }
        )
        vim.keymap.set(
          "n",
          "<leader>dr",
          function() vim.cmd.RustLsp("debuggables") end,
          { desc = "Rust Debuggables", buffer = bufnr }
        )
      end,
      default_settings = {
        -- rust-analyzer language server configuration
        ["rust-analyzer"] = {
          cargo = {
            allFeatures = true,
            loadOutDirsFromCheck = true,
            buildScripts = {
              enable = true,
            },
          },
          -- Add clippy lints for Rust.
          checkOnSave = true,
          procMacro = {
            enable = true,
            ignored = {
              ["async-trait"] = { "async_trait" },
              ["napi-derive"] = { "napi" },
              ["async-recursion"] = { "async_recursion" },
            },
          },
        },
      },
    },
  }
  vim.g.rustaceanvim = vim.tbl_deep_extend("keep", vim.g.rustaceanvim or {}, opts or {})
end

function H.texlab()
  local desc = "Vimtex Docs"
  H.on_attach(function(_, buffer) -- client
    vim.keymap.set("n", "<Leader>K", "<plug>(vimtex-doc-package)", { desc = desc, silent = true, buffer = buffer })
  end, "texlab")
  return {}
end

--          ╭─────────────────────────────────────────────────────────╮
--          │                          Setup                          │
--          ╰─────────────────────────────────────────────────────────╯
H.on_attach(function(client, buffer) -- keymaps
  H.keys(client, buffer) -- are always set regardles of capabilities
end)

if H.opts.inlay_hints.auto then H.auto_inlay_hints() end
if H.opts.codeLens.auto then H.codelens() end

local capabilities = vim.lsp.protocol.make_client_capabilities()
local has_cmp, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
capabilities = vim.tbl_deep_extend("force", capabilities, has_cmp and cmp_nvim_lsp.default_capabilities() or {})

-- the servers below are setup by mason
local servers = {
  bashls = {},
  jsonls = H.jsonls(),
  -- ltex = {}, -- grammar/spelling checker, needs jre(installed jre-openjdk-headless)
  lua_ls = H.lua_ls(),
  marksman = {},
  pyright = {}, -- test basedpyright, semantic highlighting
  ruff = H.ruff(), -- test, replaced ruff_lsp
  taplo = {}, -- toml
  texlab = H.texlab(), -- latex
  yamlls = H.yamlls(),
}
local ensure_installed = vim.tbl_keys(servers or {})

require("mason-lspconfig").setup({
  ensure_installed = ensure_installed,
  handlers = {
    function(server_name)
      -- do nothing if the server is not setup by mason:
      if not vim.tbl_contains(ensure_installed, server_name) then return end

      local server = servers[server_name] or {}
      server.capabilities = vim.tbl_deep_extend("force", {}, capabilities, server.capabilities or {})
      require("lspconfig")[server_name].setup(server)
    end,
  },
})

-- servers without mason:
H.rust_analyzer(capabilities)
