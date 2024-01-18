local M = {}

local start_spec = {
  {
    "nvim-lua/plenary.nvim",
  },
  {
    "ThePrimeagen/harpoon",
    -- branch = "harpoon2",
    -- config = function()
    --   -- require("ak.config.harpoon")
    --   require("ak.config.harpoon_one")
    -- end,
  },
}

function M.spec()
  return start_spec
end

function M.setup()
  require("ak.config.harpoon_one")
end

return M
