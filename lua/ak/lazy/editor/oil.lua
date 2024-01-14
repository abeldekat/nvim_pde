return {
  "stevearc/oil.nvim",
  init = function() -- see LazyVim, neotree
    if vim.fn.argc() == 1 then
      ---@diagnostic disable-next-line: param-type-mismatch
      local stat = vim.loop.fs_stat(vim.fn.argv(0))
      if stat and stat.type == "directory" then
        require("oil")
      end
    end
  end,
  dependencies = { "nvim-tree/nvim-web-devicons" },
  keys = { { "mk", "<cmd>Oil<cr>", desc = "Oil Open Directory" } },
  config = function()
    local opts = {
      keymaps = { -- ["g?"] = "actions.show_help",
        ["<CR>"] = false,
        ["l"] = "actions.select", --  "CR"
        ["<C-h>"] = false,
        ["<C-s>"] = "actions.select_split", --  "C-h" window navigation
        ["<C-v>"] = "actions.select_vsplit", -- "C-s"
        ["<C-c>"] = false,
        ["q"] = "actions.close", --  "<C-c>"
        ["<C-l>"] = false,
        ["<C-r>"] = "actions.refresh", --  "C-l" window navigation
        ["-"] = false,
        ["h"] = "actions.parent", --  "-"
        ["_"] = false, -- "actions.open_cwd"
      },
      use_default_keymaps = true, -- false
    }
    require("oil").setup(opts)
  end,
}
