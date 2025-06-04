local M = {}

local Toggle = {}

function Toggle.add_toggle(opts)
  if Toggle.name and Toggle.name == opts.name then return end

  Toggle.name = opts.name
  Toggle.current = 1

  vim.keymap.set("n", opts.key and opts.key or "<leader>h", function()
    Toggle.current = Toggle.current == #opts.flavours and 1 or (Toggle.current + 1)
    local flavour = opts.flavours[Toggle.current]

    if opts.toggle then
      opts.toggle(flavour)
    else
      vim.cmd.colorscheme(flavour)
    end

    vim.defer_fn(function()
      local info = string.format("Using %s[%s]", opts.name, vim.inspect(flavour))
      vim.api.nvim_echo({ { info, "InfoMsg" } }, true, {})
    end, 250)
  end, { desc = "Theme flavours" })
end

function M.add(pattern, toggle_opts)
  vim.api.nvim_create_autocmd("ColorScheme", {
    pattern = type(pattern) == string and { pattern } or pattern,
    callback = function() Toggle.add_toggle(toggle_opts) end,
  })
end

return M
