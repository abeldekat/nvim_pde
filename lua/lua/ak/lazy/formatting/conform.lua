local Util = require("ak.util")

-- use formatter.prepend_args, not formatter.extra_args
-- don't set opts.{ "format_on_save", "format_after_save" }
local get_opts = function()
  return {
    -- options to use when formatting with the conform.nvim formatter
    format = {
      timeout_ms = 3000,
      async = false, -- not recommended to change
      quiet = false, -- not recommended to change
    },
    ---@type table<string, conform.FormatterUnit[]>
    formatters_by_ft = {
      lua = { "stylua" },
      sh = { "shfmt" },
      python = { "black" },
      sql = { "sql-formatter" },
    },
    -- The options you set here will be merged with the builtin formatters.
    -- You can also define any custom formatters here.
    ---@type table<string, conform.FormatterConfigOverride|fun(bufnr: integer): nil|conform.FormatterConfigOverride>
    formatters = {
      injected = { options = { ignore_errors = true } },
      -- # Example of using dprint only when a dprint.json file is present
      -- dprint = {
      --   condition = function(ctx)
      --     return vim.fs.find({ "dprint.json" }, { path = ctx.filename, upward = true })[1]
      --   end,
      -- },
      --
      -- # Example of using shfmt with extra args
      -- shfmt = {
      --   prepend_args = { "-i", "2", "-ci" },
      -- },
    },
  }
end

return {
  "stevearc/conform.nvim",
  cmd = "ConformInfo",
  keys = {
    {
      "<leader>cF",
      function()
        require("conform").format({ formatters = { "injected" } })
      end,
      mode = { "n", "v" },
      desc = "Format injected langs",
    },
  },
  init = function() -- Install the conform formatter on VeryLazy
    Util.on_very_lazy(function()
      Util.format.register({
        name = "conform.nvim",
        priority = 100,
        primary = true,
        format = function(buf)
          local opts = get_opts().format
          opts["bufnr"] = buf
          require("conform").format(opts)
        end,
        sources = function(buf)
          local ret = require("conform").list_formatters(buf)
          ---@param v conform.FormatterInfo
          return vim.tbl_map(function(v)
            return v.name
          end, ret)
        end,
      })
    end)
  end,
  config = function()
    ---@type ConformOpts
    local opts = get_opts()
    require("conform").setup(opts)
  end,
}
