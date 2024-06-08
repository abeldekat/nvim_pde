---@param buf? number
local function is_format_on_save_enabled(buf)
  buf = (buf == nil or buf == 0) and vim.api.nvim_get_current_buf() or buf
  local globally = vim.g.format_on_save
  local on_buffer = vim.b[buf].format_on_save

  if on_buffer ~= nil then -- use buffer when set
    return on_buffer
  end
  return globally == nil or globally -- use global when set or true by default
end

---@param buf? boolean
local function toggle_format_on_save(buf)
  if buf then
    ---@diagnostic disable-next-line: inject-field
    vim.b.format_on_save = not is_format_on_save_enabled()
  else
    vim.g.format_on_save = not is_format_on_save_enabled()
    ---@diagnostic disable-next-line: inject-field
    vim.b.format_on_save = nil
  end
end

-- The default arguments for conform.format
-- Used directly or via conform's format_on_save
---@param bufnr? number
local function get_defaults(bufnr)
  local result = {}
  if bufnr == nil then
    bufnr = vim.api.nvim_get_current_buf()
    result["bufnr"] = bufnr
  end

  result["timeout_ms"] = 3000 -- markdownlint timeout
  -- kickstart:
  -- Disable "format_on_save lsp_fallback" for languages that don't
  -- have a well standardized coding style. You can add additional
  -- languages here or re-enable it for the disabled ones.
  -- local disable_filetypes = { c = true, cpp = true }
  -- return {
  --   timeout_ms = 500,
  --   lsp_fallback = not disable_filetypes[vim.bo[bufnr].filetype],
  -- }
  -- Use lsp formatting for certain filetypes:
  result["lsp_fallback"] = vim.tbl_contains({ "c", "json", "jsonc", "rust" }, vim.bo[bufnr].filetype)
  return result
end

-- Calling conform directly instead of via format_on_save:
local function format() require("conform").format(get_defaults()) end

local function add_keys()
  local keys = vim.keymap.set

  -- ── format_on_save: ───────────────────────────────────────────────────
  keys("n", "<leader>uf", function() -- from keymaps.lua
    toggle_format_on_save()
  end, { desc = "Toggle auto format (global)", silent = true })
  keys("n", "<leader>uF", function() -- from keymaps.lua
    toggle_format_on_save(true)
  end, { desc = "Toggle auto format (buffer)", silent = true })

  -- ── format directly: ──────────────────────────────────────────────────
  keys({ "n", "v" }, "<leader>cf", function() -- from keymaps.lua
    format()
  end, { desc = "Format", silent = true })

  keys(
    { "n", "v" },
    "<leader>cF",
    function() require("conform").format({ formatters = { "injected" }, timeout_ms = 3000 }) end,
    { desc = "Format injected langs", silent = true }
  )
end

local function get_opts()
  return {
    -- ---@type table<string, conform.FormatterUnit[]>
    formatters_by_ft = {
      lua = { "stylua" },
      sh = { "shfmt" },
      python = { "black" },

      ["javascript"] = { "prettier" },
      ["javascriptreact"] = { "prettier" },
      ["typescript"] = { "prettier" },
      ["typescriptreact"] = { "prettier" },
      ["vue"] = { "prettier" },
      ["css"] = { "prettier" },
      ["scss"] = { "prettier" },
      ["less"] = { "prettier" },
      ["html"] = { "prettier" },
      ["json"] = { "prettier" },
      ["jsonc"] = { "prettier" },
      ["yaml"] = { "prettier" },
      -- ["markdown"] = { "prettier" },
      -- ["markdown.mdx"] = { "prettier" },
      ["graphql"] = { "prettier" },
      ["handlebars"] = { "prettier" },

      ["markdown"] = { "prettier", "markdownlint", "markdown-toc" },
      ["markdown.mdx"] = { "prettier", "markdownlint", "markdown-toc" },
      sql = { "sqlfluff" },
      mysql = { "sqlfluff" },
      plsql = { "sqlfluff" },
    },
    -- https://github.com/stevearc/conform.nvim/blob/master/doc/advanced_topics.md#injected-language-formatting-code-blocks
    formatters = {
      injected = { options = { ignore_errors = true } },
      sqlfluff = { args = { "format", "--dialect=ansi", "-" } },
    },
    format_on_save = function(bufnr) return is_format_on_save_enabled(bufnr) and get_defaults(bufnr) or nil end,
  }
end

local function setup()
  -- opt.formatoptions = "jcroqlnt" -- tcqj -- In options.lua:
  -- Use conform for gq:
  vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
  vim.g.format_on_save = true

  require("conform").setup(get_opts())
  add_keys()

  vim.api.nvim_create_user_command("Format", function() format() end, { desc = "Format selection or buffer" })
end
setup()
