return {
  "linux-cultist/venv-selector.nvim",
  keys = { { "<leader>cv", "<cmd>:VenvSelect<cr>", desc = "Select VirtualEnv" } },
  cmd = "VenvSelect",
  config = function()
    local opts = {
      name = {
        "venv",
        ".venv",
        "env",
        ".env",
      },
    }
    if require("ak.util").has("nvim-dap-python") then
      opts.dap_enabled = true
    end
    require("venv-selector").setup(opts)
  end,
}
