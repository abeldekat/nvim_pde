vim.api.nvim_create_autocmd("User", {
  group = vim.api.nvim_create_augroup("AkRepeatableMove", {}),
  pattern = "AkRepeatableMoveToggled",
  callback = function(event)
    if event.data.enabled then
      vim.cmd("EyelinerDisable")
    else
      vim.cmd("EyelinerEnable")
    end
  end,
})
require("eyeliner").setup({
  highlight_on_key = true, -- show highlights only after keypress
  dim = true, -- dim all other characters if set to true (recommended!)
})
