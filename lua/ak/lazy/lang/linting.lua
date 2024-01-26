local function lazyfile()
  return { "BufReadPost", "BufNewFile", "BufWritePre" }
end

return {
  {
    "mfussenegger/nvim-lint",
    event = lazyfile(),
    config = function()
      require("ak.config.lang.linting")
    end,
  },
}
