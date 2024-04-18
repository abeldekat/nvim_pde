local function no_op() end

local get_opts = function()
  return {
    -- Can be a list of adapters like what neotest expects,
    -- or a list of adapter names,
    -- or a table of adapter names, mapped to adapter configs.
    -- The adapter will then be automatically loaded with the config.
    adapters = {
      -- ["neotest-python"] = {
      --   -- Here you can specify the settings for the adapter, i.e.
      --   -- runner = "pytest",
      --   -- python = ".venv/bin/python",
      --   --   opts.adapters["neotest-python"] = {
      --   --     dap = { justMyCode = false },
      --   --     -- runner = "pytest",
      --   --     -- args = { "--log-level", "DEBUG" },
      --   --   }
      -- },
    },
    -- Example for loading neotest-go with a custom config
    -- adapters = {
    --   ["neotest-go"] = {
    --     args = { "-tags=integration" },
    --   },
    -- },
    status = { virtual_text = true },
    output = { open_on_run = true },
    quickfix = {
      open = function() vim.cmd("copen") end,
    },
  }
end

local function map(l, r, opts, mode)
  mode = mode or "n"
  opts["silent"] = opts.silent ~= false
  vim.keymap.set(mode, l, r, opts)
end

local function keys()
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

  map("<leader>tL", no_op, { desc = "No-op neotest" })
end

local function setup()
  local opts = get_opts()
  local neotest_ns = vim.api.nvim_create_namespace("neotest")
  vim.diagnostic.config({
    virtual_text = {
      format = function(diagnostic)
        -- Replace newline and tab characters with space for more compact diagnostics
        local message = diagnostic.message:gsub("\n", " "):gsub("\t", " "):gsub("%s+", " "):gsub("^%s+", "")
        return message
      end,
    },
  }, neotest_ns)

  if opts.adapters then
    local adapters = {}
    for name, config in pairs(opts.adapters or {}) do
      if type(name) == "number" then
        if type(config) == "string" then config = require(config) end
        adapters[#adapters + 1] = config
      elseif config ~= false then
        local adapter = require(name)
        if type(config) == "table" and not vim.tbl_isempty(config) then
          local meta = getmetatable(adapter)
          if adapter.setup then
            adapter.setup(config)
          elseif meta and meta.__call then
            adapter(config)
          else
            error("Adapter " .. name .. " does not support setup")
          end
        end
        adapters[#adapters + 1] = adapter
      end
    end
    opts.adapters = adapters
  end

  require("neotest").setup(opts)
  keys()
end

setup()
