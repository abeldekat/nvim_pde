local Util = require("ak.util") -- only for warn...

local function debounce(ms, fn)
  local timer = vim.uv.new_timer()
  return function(...)
    local argv = { ... }
    if timer then
      timer:start(ms, 0, function()
        timer:stop()
        vim.schedule_wrap(fn)(unpack(argv))
      end)
    end
  end
end

local function lint(lint_module)
  -- Use nvim-lint's logic first:
  -- * checks if linters exist for the full filetype first
  -- * otherwise will split filetype by "." and add all those linters
  -- * this differs from conform.nvim which only uses the first filetype that has a formatter
  local names = lint_module._resolve_linter_by_ft(vim.bo.filetype)
  -- Create a copy of the names table to avoid modifying the original:
  names = vim.list_extend({}, names)

  -- Add fallback linters.
  if #names == 0 then vim.list_extend(names, lint_module.linters_by_ft["_"] or {}) end

  -- Add global linters.
  vim.list_extend(names, lint_module.linters_by_ft["*"] or {})

  -- Filter out linters that don't exist or don't match the condition.
  local ctx = { filename = vim.api.nvim_buf_get_name(0) }
  ctx.dirname = vim.fn.fnamemodify(ctx.filename, ":h")
  names = vim.tbl_filter(function(name)
    local linter = lint_module.linters[name]
    if not linter then Util.warn("Linter not found: " .. name, { title = "nvim-lint" }) end
    return linter and not (type(linter) == "table" and linter.condition and not linter.condition(ctx))
  end, names)

  -- Run linters.
  if #names > 0 then lint_module.try_lint(names) end
end

local function get_opts()
  return {
    -- Event to trigger linters
    events = { "BufWritePost", "BufReadPost", "InsertLeave" },
    linters_by_ft = {
      markdown = { "markdownlint-cli2" },
      sql = { "sqlfluff" },
      mysql = { "sqlfluff" },
      plsql = { "sqlfluff" },
    },
  }
end

local lint_module = require("lint")
local opts = get_opts()
lint_module.linters_by_ft = opts.linters_by_ft
vim.api.nvim_create_autocmd(opts.events, {
  group = vim.api.nvim_create_augroup("nvim-lint", { clear = true }),
  callback = debounce(100, function() lint(lint_module) end),
})
