local Util = require("util")
return {
  server = {},
  setup = function()
    Util.lsp.on_attach(function(client, buffer)
      if client.name == "ruff_lsp" then
        vim.keymap.set("n", "<leader>co", function()
          vim.lsp.buf.code_action({
            apply = true,
            context = {
              only = { "source.organizeImports" },
              diagnostics = {},
            },
          })
        end, { desc = "Organize imports", silent = true, buffer = buffer })

        -- Disable hover in favor of Pyright
        client.server_capabilities.hoverProvider = false
      end
    end)
  end,
}
