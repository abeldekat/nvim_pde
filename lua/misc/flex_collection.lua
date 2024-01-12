local M = {}

-- Plenary as LazyVim placeholder. Always load

local presets = {
  coding = {
    "luasnip",
    "friendly-snippets",
    "nvim-cmp",
    "cmp-nvim-lsp",
    "cmp-buffer",
    "cmp-path",
    "cmp_luasnip",
    "nvim-ts-context-commentstring",
    "nvim-autopairs",
    "comment.nvim",
    "nvim-surround",
    "substitute",
    "dial",
  },
  colorscheme = { "tokyonight", "catppuccin" }, -- and more
  editor = {
    "aerial",
    "nvim-spectre",
    "telescope.nvim",
    "telescope-fzf-native.nvim",
    "flash",
    "which-key",
    "gitsigns",
    "vim-illuminate",
    "trouble",
    "todo-comments",
    -- "telescope-zoxide", -- disabled for now
    -- "telescope-file-browser.nvim", -- disabled for now
    -- "telescope-project.nvim", -- disabled for now
    "eyeliner.nvim",
    "vim-hardtime",
    "toggleterm",
    "harpoon",
    "oil",
    "git-blame",
  },
  formatting = { "conform.nvim" },
  linting = { "nvim-lint" },
  lsp = {
    "nvim-lspconfig",
    "neoconf",
    "neodev",
    "mason.nvim",
    "mason-lspconfig.nvim",
    "schemastore",
  },
  treesitter = {
    "treesitter",
    "nvim-treesitter-textobjects",
    "nvim-treesitter-context",
    "nvim-ts-autotag",
  },
  ui = {
    "dressing",
    "lualine",
    "indent-blankline",
    "web-devicons",
    "nui.nvim",
    "dashboard",
    "fidget",
  },
  util = {
    "vim-startuptime",
    "persistence",
    "vim-slime",
  },
}

local when_enabling = {
  editor = { "plenary" },
}

M.get_preset_keywords = function(name, enable_on_match)
  local result = presets[name]

  if result and enable_on_match then
    local extra = when_enabling[name]
    if extra then
      result = vim.list_extend(vim.list_extend({}, result), extra)
    end
  end
  return result or {}
end

M.change_settings = function(settings)
  if settings.options == false then
    package.loaded["config.options"] = true
    vim.g.mapleader = " "
    vim.g.maplocalleader = "\\"
  end
  if settings.autocmds == false then
    package.loaded["config.autocmds"] = true
  end
  if settings.keymaps == false then
    package.loaded["config.keymaps"] = true
  end

  return {}
end

return M
