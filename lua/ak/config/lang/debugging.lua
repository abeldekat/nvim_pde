local Util = require("ak.util")
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
  local dap = require("dap")
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
    handlers = {},

    -- You'll need to check that you have the required things installed
    -- online, please don't ask me how to install them :)
    ensure_installed = {
      -- Update this to ensure that you have the debuggers for the langs you want
    },
  }
  require("mason-nvim-dap").setup(opts)
end

local function python_dap()
  local path = require("mason-registry").get_package("debugpy"):get_install_path()
  require("dap-python").setup(path .. "/venv/bin/python")
  Util.register_referenced("nvim-dap-python")

  -- keys for ft = python
  map("<leader>dPt", function() require("dap-python").test_method() end, { desc = "Python debug method" })
  map("<leader>dPc", function() require("dap-python").test_class() end, { desc = "Python debug class" })
end

local function keys()
  ---@param config {args?:string[]|fun():string[]?}
  local function get_args(config)
    local args = type(config.args) == "function" and (config.args() or {}) or config.args or {}
    config = vim.deepcopy(config)
    ---@cast args string[]
    config.args = function()
      ---@diagnostic disable-next-line: redundant-parameter
      local new_args = vim.fn.input("Run with args: ", table.concat(args, " ")) --[[@as string]]
      return vim.split(vim.fn.expand(new_args) --[[@as string]], " ")
    end
    return config
  end
  map(
    "<leader>dB",
    function() require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: ")) end,
    { desc = "Breakpoint condition" }
  )
  map("<leader>db", function() require("dap").toggle_breakpoint() end, { desc = "Toggle breakpoint" })
  map("<leader>dc", function() require("dap").continue() end, { desc = "Continue" })
  map("<leader>da", function() require("dap").continue({ before = get_args }) end, { desc = "Run with args" })
  map("<leader>dC", function() require("dap").run_to_cursor() end, { desc = "Run to cursor" })
  map("<leader>dg", function() require("dap").goto_() end, { desc = "Go to line (no execute)" })
  map("<leader>di", function() require("dap").step_into() end, { desc = "Step into" })
  map("<leader>dj", function() require("dap").down() end, { desc = "down" })
  map("<leader>dk", function() require("dap").up() end, { desc = "Up" })
  map("<leader>dl", function() require("dap").run_last() end, { desc = "Run last" })
  map("<leader>do", function() require("dap").step_out() end, { desc = "Step out" })
  map("<leader>dO", function() require("dap").step_over() end, { desc = "Step over" })
  map("<leader>dp", function() require("dap").pause() end, { desc = "Pause" })
  map("<leader>dr", function() require("dap").repl.toggle() end, { desc = "Toggle REPL" })
  map("<leader>ds", function() require("dap").session() end, { desc = "Session" })
  map("<leader>dt", function() require("dap").terminate() end, { desc = "Terminate" })
  map("<leader>dw", function() require("dap.ui.widgets").hover() end, { desc = "Widgets" })

  -- neotest
  map("<leader>td", function()
    ---@diagnostic disable-next-line: missing-fields
    require("neotest").run.run({ strategy = "dap" })
  end, { desc = "Debug nearest" })

  map("<leader>dL", no_op, { desc = "No-op dap" })
end

local function setup()
  ui()
  virtual_text()
  mason_dap()
  python_dap()
  keys()

  vim.api.nvim_set_hl(0, "DapStoppedLine", { default = true, link = "Visual" })
  for name, sign in pairs(require("ak.consts").icons.dap) do
    sign = type(sign) == "table" and sign or { sign }
    vim.fn.sign_define(
      "Dap" .. name,
      { text = sign[1], texthl = sign[2] or "DiagnosticInfo", linehl = sign[3], numhl = sign[3] }
    )
  end
end

setup()
