return {

  { -- Markdown preview
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    build = function()
      vim.fn["mkdp#util#install"]()
    end,
    keys = {
      {
        "<leader>cp",
        ft = "markdown",
        "<cmd>MarkdownPreviewToggle<cr>",
        desc = "Markdown Preview",
      },
    },
    config = function()
      vim.cmd([[do FileType]])
    end,
  },

  {
    "toppair/peek.nvim", -- toppair/peek.nvim
    -- enabled = function()
    --   if vim.fn.executable("deno") == 1 then
    --     return true
    --   end
    --   require("lazyvim.util").warn({
    --     "`peek.nvim` requires `deno` to be installed.\n",
    --     "To hide this message, install `deno` or disable the `toppair/peek.nvim` plugin.",
    --   }, { title = "LazyVim Extras `lang.markdown`" })
    --   return false
    -- end,
    build = "deno task --quiet build:fast",
    keys = {
      {
        "<leader>ck",
        ft = "markdown",
        function()
          local peek = require("peek")
          if peek.is_open() then
            peek.close()
          else
            peek.open()
          end
        end,
        desc = "Pee[k] (Markdown Preview)",
      },
    },
    config = function()
      require("peek").setup({ theme = "light" })
    end,
  },

  {
    "lukas-reineke/headlines.nvim",
    enabled = true, -- sometime flickers...
    ft = { "markdown", "norg", "rmd", "org" },
    config = function()
      local opts = {}
      for _, ft in ipairs({ "markdown", "norg", "rmd", "org" }) do
        opts[ft] = {
          headline_highlights = {},
        }
        for i = 1, 6 do
          local hl = "Headline" .. i
          vim.api.nvim_set_hl(0, hl, { link = "Headline", default = true })
          table.insert(opts[ft].headline_highlights, hl)
        end
      end
      opts.markdown = {
        -- https://github.com/lukas-reineke/headlines.nvim/issues/41#issuecomment-1556334775
        fat_headline_lower_string = "▔",
      }

      -- PERF: schedule to prevent headlines slowing down opening a file
      vim.schedule(function()
        require("headlines").setup(opts)
        require("headlines").refresh()
      end)
    end,
  },
}
