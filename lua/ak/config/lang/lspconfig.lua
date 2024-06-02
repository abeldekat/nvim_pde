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
local H = {}

-- perhaps: LazyVim rename file

-- perhaps:
-- {
--   workspace = { -- mariasolos
--     -- PERF: didChangeWatchedFiles is too slow.
--     -- TODO: Remove this when https://github.com/neovim/neovim/issues/23291#issuecomment-1686709265 is fixed.
--     didChangeWatchedFiles = { dynamicRegistration = false },
--   },
-- }

function H.inlay_hints()
  if vim.lsp.inlay_hint then
    Util.lsp.on_attach(function(client, buffer) -- set to false by default
      if client.supports_method("textDocument/inlayHint") then Util.toggle.inlay_hints(buffer, false) end
    end)
  end
end

function H.codelens()
  if vim.lsp.codelens then
    Util.lsp.on_attach(function(client, buffer)
      if client.supports_method("textDocument/codeLens") then
        vim.lsp.codelens.refresh()
        vim.api.nvim_create_autocmd({ "BufEnter", "InsertLeave" }, { --  "CursorHold"
          buffer = buffer,
          callback = vim.lsp.codelens.refresh,
        })
      end
    end)
  end
end

function H.keys(_, buffer) -- client
  local function map(l, r, opts, mode)
    mode = mode or "n"
    opts["buffer"] = buffer
    opts["silent"] = opts.silent ~= false
    vim.keymap.set(mode, l, r, opts)
  end
  map("<leader>cl", "<cmd>LspInfo<cr>", { desc = "Lsp info" })
  map("gd", "<cmd>Telescope lsp_definitions reuse_win=true<cr>", { desc = "Goto definition" })
  map("gr", "<cmd>Telescope lsp_references<cr>", { desc = "References", nowait = true })
  map("gD", vim.lsp.buf.declaration, { desc = "Goto declaration" })
  map("gI", "<cmd>Telescope lsp_implementations reuse_win=true<cr>", { desc = "Goto implementation" })
  map("gy", "<cmd>Telescope lsp_type_definitions reuse_win=true<cr>", { desc = "Goto type definition" })
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

  -- Also possible
  -- local methods = vim.lsp.protocol.Methods
  -- if client.supports_method(methods.textDocument_codeAction) then
  -- end
end

-- Assumption: .luarc.jsonc takes precendence. Individual values override,
-- arrays are not merged
-- Example: diagnostics global array, "one" in lua_ls settings,
-- and "two" in .luarc.json -> Only a warning on global "one"
-- NOTE: when uncommenting a library block in .luarc.jsonc, the completion
-- becomes available without restarting nvim
function H.lua_ls()
  return {
    settings = {
      Lua = {
        runtime = { version = "LuaJIT" },
        codeLens = { enable = true },
        completion = { callSnippet = "Replace" },
        diagnostics = { globals = { "vim" } },
        doc = { privateName = { "^_" } },
        hint = {
          enable = true,
          setType = false,
          paramType = true,
          paramName = "Disable",
          semicolon = "Disable",
          arrayIndex = "Disable",
        },
        workspace = {
          checkThirdParty = false,
          library = {
            vim.env.VIMRUNTIME,
            "${3rd}/luv/library",
            -- "${3rd}/busted/library",
          },
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
  Util.lsp.on_attach(function(client, buffer)
    if client.name ~= "ruff" then return end
    vim.keymap.set(
      "n",
      "<leader>co",
      function()
        vim.lsp.buf.code_action({
          apply = true,
          context = {
            only = { "source.organizeImports" },
            diagnostics = {},
          },
        })
      end,
      { desc = "Organize imports", silent = true, buffer = buffer }
    )

    -- Disable hover in favor of Pyright
    client.server_capabilities.hoverProvider = false
  end)
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
          checkOnSave = {
            allFeatures = true,
            command = "clippy",
            extraArgs = { "--no-deps" },
          },
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

--          ╭─────────────────────────────────────────────────────────╮
--          │                          Setup                          │
--          ╰─────────────────────────────────────────────────────────╯
Util.lsp.on_attach(function(client, buffer) -- keymaps
  H.keys(client, buffer) -- are always set regardles of capabilities
end)

H.inlay_hints()
-- H.codelens() -- needs a toggle....

local capabilities = vim.lsp.protocol.make_client_capabilities()
local has_cmp, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
capabilities = vim.tbl_deep_extend("force", capabilities, has_cmp and cmp_nvim_lsp.default_capabilities() or {})

-- the servers below are setup by mason
local servers = {
  bashls = {},
  jsonls = H.jsonls(),
  lua_ls = H.lua_ls(),
  marksman = {},
  pyright = {},
  ruff = H.ruff(),
  taplo = {}, -- toml
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
      -- Useful when disabling certain features (for example, turning off formatting for tsserver)
      server.capabilities = vim.tbl_deep_extend("force", {}, capabilities, server.capabilities or {})
      require("lspconfig")[server_name].setup(server)
    end,
  },
})

-- servers without mason:
H.rust_analyzer(capabilities)
