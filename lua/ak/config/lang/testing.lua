local function no_op() end

local get_opts = function()
  return {
    status = { virtual_text = true },
    output = { open_on_run = true },
    quickfix = {
      open = function() vim.cmd("copen") end,
    },
    adapters = { require("rustaceanvim.neotest") },
  }
end

local function keys()
  local function map(l, r, opts, mode)
    mode = mode or "n"
    opts["silent"] = opts.silent ~= false
    vim.keymap.set(mode, l, r, opts)
  end

  map("<leader>ta", function()
    for _, adapter_id in ipairs(require("neotest").run.adapters()) do
      require("neotest").run.run({ suite = true, adapter = adapter_id })
    end
  end, { desc = "Run suite" })
  map("<leader>tl", function() require("neotest").run.run_last() end, { desc = "Run last" })
  map("<leader>tt", function() require("neotest").run.run(vim.fn.expand("%")) end, { desc = "Run file" })
  map("<leader>tT", function() require("neotest").run.run(vim.uv.cwd()) end, { desc = "Run All Test Files" })
  map(
    "<leader>tr",
    ---@diagnostic disable-next-line: missing-fields
    function() require("neotest").run.run({ extra_args = { "-s", "-vvv" } }) end,
    { desc = "Run nearest" }
  )
  map("<leader>ts", function() require("neotest").summary.toggle() end, { desc = "Toggle summary" })
  map(
    "<leader>to",
    function() require("neotest").output.open({ enter = true, auto_close = true }) end,
    { desc = "Show output" }
  )
  map("<leader>tO", function() require("neotest").output_panel.toggle() end, { desc = "Toggle output panel" })
  map("<leader>tS", function() require("neotest").run.stop() end, { desc = "Stop" })
  map("<leader>tw", function() require("neotest").watch.toggle(vim.fn.expand("%")) end, { desc = "Toggle watch" })

  map("<leader>tL", no_op, { desc = "No-op neotest" })
end

local function setup()
  local neotest_ns = vim.api.nvim_create_namespace("neotest")
  vim.diagnostic.config({
    virtual_text = {
      format = function(diagnostic) -- replace newline and tab for compact diagnostics
        local message = diagnostic.message:gsub("\n", " "):gsub("\t", " "):gsub("%s+", " "):gsub("^%s+", "")
        return message
      end,
    },
  }, neotest_ns)

  require("neotest").setup(get_opts())
  keys()
end

setup()
