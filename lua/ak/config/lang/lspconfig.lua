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
  --
  -- Used to be gy. gy can also be used to copy to clipboard
  map("gY", Picker.lsp_type_definitions, { desc = "Goto type definition" })
  --   map("K", function() vim.lsp.buf.hover() end, { desc = "Hover" }) -- builtin, see lsp-defaults
  map("gK", function() vim.lsp.buf.signature_help() end, { desc = "Signature help" })
  --
  -- used to be <c-k>, now used for snippet expansion:
  map("<c-s>", function() vim.lsp.buf.signature_help() end, { desc = "Signature help" }, "i")
  --
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
--
function H.lua_ls() -- Mostly copied from nvim echasnovski...
  --
  -- LuaLS "Go to source" =======================================================
  -- Deal with the fact that LuaLS in case of `local a = function()` style
  -- treats both `a` and `function()` as definitions of `a`.
  -- Do this by tweaking `vim.lsp.buf_definition` mapping as client-local
  -- handlers are ignored after https://github.com/neovim/neovim/pull/30877
  local filter_line_locations = function(locations)
    local present, res = {}, {}
    for _, l in ipairs(locations) do
      local t = present[l.filename] or {}
      if not t[l.lnum] then
        table.insert(res, l)
        t[l.lnum] = true
      end
      present[l.filename] = t
    end
    return res
  end

  local show_location = function(location)
    local buf_id = location.bufnr or vim.fn.bufadd(location.filename)
    vim.bo[buf_id].buflisted = true
    vim.api.nvim_win_set_buf(0, buf_id)
    vim.api.nvim_win_set_cursor(0, { location.lnum, location.col - 1 })
    vim.cmd("normal! zv")
  end

  local on_list = function(args)
    local items = filter_line_locations(args.items)
    if #items > 1 then
      vim.fn.setqflist({}, " ", { title = "LSP locations", items = items })
      return vim.cmd("botright copen")
    end
    show_location(items[1])
  end

  local luals_unique_definition = function() return vim.lsp.buf.definition({ on_list = on_list }) end

  return {
    on_attach = function(client, bufnr)
      -- Reduce unnecessarily long list of completion triggers for better
      -- 'mini.completion' experience
      client.server_capabilities.completionProvider.triggerCharacters = { ".", ":" }

      -- Override global "Go to source" mapping with dedicated buffer-local
      local opts = { buffer = bufnr, desc = "Goto definition" }
      vim.keymap.set("n", "gd", luals_unique_definition, opts)
    end,
    settings = {
      Lua = {
        runtime = {
          -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
          version = "LuaJIT",
          -- Setup your lua path
          path = vim.split(package.path, ";"),
        },
        diagnostics = {
          -- Get the language server to recognize common globals
          globals = { "vim", "describe", "it", "before_each", "after_each" },
          -- disable = { "need-check-nil" },
          -- Don't make workspace diagnostic, as it consumes too much CPU and RAM
          workspaceDelay = -1,
        },
        telemetry = { enable = false },
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
          files = {
            excludeDirs = {
              ".direnv",
              ".git",
              ".github",
              ".gitlab",
              "bin",
              "node_modules",
              "target",
              "venv",
              ".venv",
            },
          },
        },
      },
    },
  }
  vim.g.rustaceanvim = vim.tbl_deep_extend("keep", vim.g.rustaceanvim or {}, opts or {})
end

-- TODO: test ltex-plus
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
if Util.cmp == "blink" then
  capabilities = vim.tbl_deep_extend("force", {}, require("blink.cmp").get_lsp_capabilities(capabilities))
elseif Util.cmp == "nvim-cmp" then
  local has_cmp, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
  capabilities = vim.tbl_deep_extend("force", capabilities, has_cmp and cmp_nvim_lsp.default_capabilities() or {})
end

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
  zls = {}, -- zig
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
