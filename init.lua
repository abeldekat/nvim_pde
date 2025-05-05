vim.loader.enable()

-- TODO: Test vim._extui
-- require("vim._extui").enable({})

-- Caching: Do all init in ak/init.lua
require("ak")({})
