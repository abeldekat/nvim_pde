-- https://rust-analyzer.github.io/
-- Install with cargo

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("ak_lsp_rust_analyzer", {}),
  callback = function(args)
    local client = assert(vim.lsp.get_client_by_id(args.data.client_id))
    if not client.name == "rust-analyzer" then return end

    -- Disable deprecation messages in rust projects originating from rustacenvim:
    ---@diagnostic disable-next-line: duplicate-set-field
    vim.deprecate = function() end

    vim.keymap.set(
      "n",
      "<leader>cR",
      function() vim.cmd.RustLsp("codeAction") end,
      { desc = "Code Action", buffer = args.buf }
    )
    vim.keymap.set(
      "n",
      "<leader>dr",
      function() vim.cmd.RustLsp("debuggables") end,
      { desc = "Rust Debuggables", buffer = args.buf }
    )
  end,
})
return {
  server = {
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
