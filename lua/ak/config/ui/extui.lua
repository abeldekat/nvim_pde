if vim.fn.has("nvim-0.12") ~= 1 then return end

require("vim._extui").enable({
  msg = {
    pos = "box", -- "cmd"
    --   box = {
    --     timeout = 2000, -- 4000
    --   },
  },
})
