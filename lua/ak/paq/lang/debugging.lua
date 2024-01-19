-- local function no_replay() end
-- keys = { { "<leader>dL", no_replay, desc = "Load dap" } },

local M = {}

local debug_spec = {
  { "rcarriga/nvim-dap-ui", opt = true },
  { "theHamsta/nvim-dap-virtual-text", opt = true },
  { "jay-babu/mason-nvim-dap.nvim", opt = true }, -- dependencies = "mason.nvim",
  { "mfussenegger/nvim-dap-python", opt = true },
  { "mfussenegger/nvim-dap", opt = true },
}

function M.spec()
  return debug_spec
end

function M.setup()
  -- require("ak.config.lang.debugging")
end
return M
