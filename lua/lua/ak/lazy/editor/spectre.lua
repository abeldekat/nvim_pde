return {
  "nvim-pack/nvim-spectre",
  build = false,
  cmd = "Spectre",
  keys = {
    {
      "<leader>sr",
      function()
        require("spectre").open()
      end,
      desc = "Replace in files (spectre)",
    },
  },
  config = function()
    require("spectre").setup({ open_cmd = "noswapfile vnew" })
  end,
}
