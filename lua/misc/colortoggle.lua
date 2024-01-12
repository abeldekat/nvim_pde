local M = {}

local name = nil
local current = 1

function M.add_toggle(opts)
  if name and name == opts.name then
    return
  end

  name = opts.name
  current = 1

  vim.keymap.set("n", opts.key and opts.key or "<leader>a", function()
    current = current == #opts.flavours and 1 or (current + 1)
    local flavour = opts.flavours[current]

    if opts.toggle then
      opts.toggle(flavour)
    else
      vim.cmd.colorscheme(flavour)
    end

    vim.defer_fn(function()
      local info = string.format("Using %s[%s]", opts.name, vim.inspect(flavour))
      vim.api.nvim_echo({ { info, "InfoMsg" } }, true, {})
    end, 250)
  end, { desc = "Alternate colors" })
end

return M
