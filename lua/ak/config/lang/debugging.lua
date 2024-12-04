local dap = require("dap")

local function no_op() end

local function map(l, r, opts, mode)
  mode = mode or "n"
  opts["silent"] = opts.silent ~= false
  vim.keymap.set(mode, l, r, opts)
end

local function ui()
  local opts = {}

  -- setup dap config by VsCode launch.json file
  -- require("dap.ext.vscode").load_launchjs()
  local dapui = require("dapui")
  dapui.setup(opts)
  dap.listeners.after.event_initialized["dapui_config"] = function() dapui.open({}) end
  dap.listeners.before.event_terminated["dapui_config"] = function() dapui.close({}) end
  dap.listeners.before.event_exited["dapui_config"] = function() dapui.close({}) end

  map("<leader>du", function() require("dapui").toggle({}) end, { desc = "Dap ui" })
  map("<leader>de", function() require("dapui").eval() end, { desc = "Eval" }, { "n", "v" })
end

local function virtual_text() require("nvim-dap-virtual-text").setup({}) end

local function mason_dap()
  local opts = {
    -- Makes a best effort to setup the various debuggers with
    -- reasonable debug configurations
    automatic_installation = true,

    -- You can provide additional configuration to the handlers,
    -- see mason-nvim-dap README for more information
    handlers = { python = function() end }, -- nvim-dap-python handlers

    -- You'll need to check that you have the required things installed
    -- online, please don't ask me how to install them :)
    ensure_installed = {
      -- Update this to ensure that you have the debuggers for the langs you want
    },
  }
  require("mason-nvim-dap").setup(opts)
end

-- local function python_dap()
--   local path = require("mason-registry").get_package("debugpy"):get_install_path()
--   require("dap-python").setup(path .. "/venv/bin/python")
--   Util.register_referenced("nvim-dap-python")
--
--   -- keys for ft = python
--   map("<leader>dPt", function() require("dap-python").test_method() end, { desc = "Python debug method" })
--   map("<leader>dPc", function() require("dap-python").test_class() end, { desc = "Python debug class" })
-- end

local function lua_dap()
  dap.adapters.nlua = function(callback, conf)
    ---@diagnostic disable-next-line: undefined-field
    local adapter = { type = "server", host = conf.host or "127.0.0.1", port = conf.port or 8086 }
    ---@diagnostic disable-next-line: undefined-field
    if conf.start_neovim then
      local dap_run = dap.run
      ---@diagnostic disable-next-line: duplicate-set-field
      dap.run = function(c)
        adapter.port = c.port
        adapter.host = c.host
      end
      require("osv").run_this()
      dap.run = dap_run
    end
    callback(adapter)
  end
  dap.configurations.lua = {
    { type = "nlua", request = "attach", name = "Run this file", start_neovim = {} },
    {
      type = "nlua",
      request = "attach",
      name = "Attach to running Neovim instance (port = 8086)",
      port = 8086,
    },
  }
end

local function keys()
  ---@param config {args?:string[]|fun():string[]?}
  local function get_args(config)
    local args = type(config.args) == "function" and (config.args() or {}) or config.args or {} --[[@as string[] | string ]]
    local args_str = type(args) == "table" and table.concat(args, " ") or args --[[@as string]]

    config = vim.deepcopy(config)
    ---@cast args string[]
    config.args = function()
      local new_args = vim.fn.expand(vim.fn.input("Run with args: ", args_str)) --[[@as string]]
      if config.type and config.type == "java" then
        ---@diagnostic disable-next-line: return-type-mismatch
        return new_args
      end
      return require("dap.utils").splitstr(new_args)
    end
    return config
  end
  map(
    "<leader>dB",
    function() require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: ")) end,
    { desc = "Breakpoint condition" }
  )
  map("<leader>db", function() dap.toggle_breakpoint() end, { desc = "Toggle breakpoint" })
  map("<leader>dc", function() dap.continue() end, { desc = "Run/Continue" })
  map("<leader>da", function() dap.continue({ before = get_args }) end, { desc = "Run with args" })
  map("<leader>dC", function() dap.run_to_cursor() end, { desc = "Run to cursor" })
  map("<leader>dg", function() dap.goto_() end, { desc = "Go to line (no execute)" })
  map("<leader>di", function() dap.step_into() end, { desc = "Step into" })
  map("<leader>dj", function() dap.down() end, { desc = "down" })
  map("<leader>dk", function() dap.up() end, { desc = "Up" })
  map("<leader>dl", function() dap.run_last() end, { desc = "Run last" })
  map("<leader>do", function() dap.step_out() end, { desc = "Step out" })
  map("<leader>dO", function() dap.step_over() end, { desc = "Step over" })
  map("<leader>dp", function() dap.pause() end, { desc = "Pause" })
  map("<leader>dr", function() dap.repl.toggle() end, { desc = "Toggle REPL" })
  map("<leader>ds", function() dap.session() end, { desc = "Session" })
  map("<leader>dt", function() dap.terminate() end, { desc = "Terminate" })
  map("<leader>dw", function() require("dap.ui.widgets").hover() end, { desc = "Widgets" })

  -- neotest
  map("<leader>td", function()
    ---@diagnostic disable-next-line: missing-fields
    require("neotest").run.run({ strategy = "dap" })
  end, { desc = "Debug nearest" })

  map("<leader>dL", no_op, { desc = "No-op dap" })
end

local function setup()
  mason_dap()
  ui()
  virtual_text()
  -- python_dap()
  lua_dap()
  keys()

  vim.api.nvim_set_hl(0, "DapStoppedLine", { default = true, link = "Visual" })
  for name, sign in pairs({
    Stopped = { "󰁕 ", "DiagnosticWarn", "DapStoppedLine" },
    Breakpoint = " ",
    BreakpointCondition = " ",
    BreakpointRejected = { " ", "DiagnosticError" },
    LogPoint = ".>",
  }) do
    sign = type(sign) == "table" and sign or { sign } --[[ @as table]]
    vim.fn.sign_define(
      "Dap" .. name,
      { text = sign[1], texthl = sign[2] or "DiagnosticInfo", linehl = sign[3], numhl = sign[3] }
    )
  end
end

setup()
