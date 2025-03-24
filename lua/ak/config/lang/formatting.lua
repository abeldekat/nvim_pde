local OnSave = { enabled = true }

---@param buf? number
OnSave.is_enabled = function(buf)
  buf = (buf == nil or buf == 0) and vim.api.nvim_get_current_buf() or buf
  local buf_format_on_save = vim.b[buf].format_on_save
  if buf_format_on_save == nil then
    return OnSave.enabled -- fallback
  else
    return buf_format_on_save
  end
end

---@param use_buf? boolean
OnSave.toggle = function(use_buf)
  if use_buf then
    vim.b.format_on_save = not OnSave.is_enabled()
  else
    vim.b.format_on_save = nil -- always clear the setting for the current buffer
    OnSave.enabled = not OnSave.enabled
  end
  OnSave.info()
end

OnSave.info = function()
  local buf = vim.api.nvim_get_current_buf()
  local gaf = OnSave.enabled
  local baf = vim.b[buf].format_on_save
  local enabled = OnSave.is_enabled(buf)
  local lines = {
    ("# format_on_save %s"):format(enabled and "enabled" or "disabled"),
    ("- [%s] global **%s**"):format(gaf and "x" or " ", gaf and "enabled" or "disabled"),
    baf == nil and "" or ("- [%s] buffer **%s**"):format(baf and "x" or " ", baf and "enabled" or "disabled"),
  }
  local level = enabled and vim.log.levels.INFO or vim.log.levels.WARN
  vim.notify(table.concat(lines, "\n"), level)
end

-- -- You can also customize some of the format options for the filetype
-- rust = { "rustfmt", lsp_format = "fallback" },
local formatters_by_ft = {
  ["css"] = { "prettier" },
  ["go"] = { "goimports", "gofumpt" },
  ["graphql"] = { "prettier" },
  ["handlebars"] = { "prettier" },
  ["html"] = { "prettier" },
  ["javascript"] = { "prettier" },
  ["javascriptreact"] = { "prettier" },
  ["json"] = { "prettier" },
  ["jsonc"] = { "prettier" },
  ["lua"] = { "stylua" },
  ["less"] = { "prettier" },
  ["markdown"] = { "prettier", "markdownlint-cli2", "markdown-toc" },
  ["markdown.mdx"] = { "prettier", "markdownlint-cli2", "markdown-toc" },
  ["mysql"] = { "sqlfluff" }, -- consider sleek
  ["plsql"] = { "sqlfluff" },
  ["python "] = { "black" },
  ["scss"] = { "prettier" },
  ["sh"] = { "shfmt" },
  ["sql"] = { "sqlfluff" },
  ["typescript"] = { "prettier" },
  ["typescriptreact"] = { "prettier" },
  ["vue"] = { "prettier" },
  ["yaml"] = { "prettier" },
}

local formatters = {
  injected = { options = { ignore_errors = true } }, -- format treesitter injected languages.
  ["markdown-toc"] = {
    condition = function(_, ctx)
      for _, line in ipairs(vim.api.nvim_buf_get_lines(ctx.buf, 0, -1, false)) do
        if line:find("<!%-%- toc %-%->") then return true end
      end
    end,
  },
  ["markdownlint-cli2"] = {
    condition = function(_, ctx)
      local diag = vim.tbl_filter(function(d) return d.source == "markdownlint" end, vim.diagnostic.get(ctx.buf))
      return #diag > 0
    end,
  },
  sqlfluff = { args = { "format", "--dialect=ansi", "-" } },
}

local function setup()
  -- opt.formatoptions = "jcroqlnt" -- tcqj -- from options.lua
  vim.o.formatexpr = "v:lua.require'conform'.formatexpr()" -- conform for gq

  require("conform").setup({
    default_format_opts = { timeout_ms = 3000, lsp_format = "fallback" },
    formatters = formatters,
    formatters_by_ft = formatters_by_ft,
    format_after_save = function(bufnr) -- async, alternative is format_on_save
      return OnSave.is_enabled(bufnr) and {} or nil
    end,
  })

  local key = vim.keymap.set
  local desc = "Format"
  local default = function() require("conform").format() end
  key({ "n", "v" }, "<leader>cf", default, { desc = desc, silent = true })

  desc = "Format injected langs"
  local injected = function() require("conform").format({ formatters = { "injected" } }) end
  key({ "n", "v" }, "<leader>cF", injected, { desc = desc, silent = true })

  desc = "Toggle auto format "
  key("n", "<leader>uf", function() OnSave.toggle() end, { desc = desc .. "(global)", silent = true })
  key("n", "<leader>uF", function() OnSave.toggle(true) end, { desc = desc .. "(buffer)", silent = true })

  vim.api.nvim_create_user_command("FormatOnSaveInfo", OnSave.info, { desc = "Show info about format_on_save" })
end
setup()
