-- vim.api.nvim_create_autocmd("LspAttach", {
--   group = vim.api.nvim_create_augroup("ak_lsp_rust_analyzer", {}),
--   callback = function(args)
--     local client = assert(vim.lsp.get_client_by_id(args.data.client_id))
--     if client.name ~= "rust-analyzer" then return end
--
--     -- Disable deprecation messages in rust projects originating from rustacenvim:
--     -- "client.request is deprecated"
--     ---@diagnostic disable-next-line: duplicate-set-field
--     vim.deprecate = function() end
--
--     vim.keymap.set(
--       "n",
--       "<leader>cR",
--       function() vim.cmd.RustLsp("codeAction") end,
--       { desc = "Code Action", buffer = args.buf }
--     )
--     vim.keymap.set(
--       "n",
--       "<leader>dr",
--       function() vim.cmd.RustLsp("debuggables") end,
--       { desc = "Rust Debuggables", buffer = args.buf }
--     )
--   end,
-- })

vim.lsp.config.rust_analyzer = {
  settings = {
    ["rust-analyzer"] = {
      cargo = {
        allFeatures = true,
        loadOutDirsFromCheck = true,
        buildScripts = {
          enable = true,
        },
      },
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
}
