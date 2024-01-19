--          ╭─────────────────────────────────────────────────────────╮
--          │           Module containing color utilities             │
--          ╰─────────────────────────────────────────────────────────╯

---@class ak.util.color
local M = {}

local Toggle = {}

function M.setup()
  Toggle.name = nil
  Toggle.current = 1
end

function Toggle.add_toggle(opts)
  if Toggle.name and Toggle.name == opts.name then
    return
  end

  Toggle.name = opts.name
  Toggle.current = 1

  vim.keymap.set("n", opts.key and opts.key or "<leader>a", function()
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
  end, { desc = "Alternate colors" })
end

function M.add_toggle(pattern, toggle_opts)
  vim.api.nvim_create_autocmd("ColorScheme", {
    pattern = type(pattern) == string and { pattern } or pattern,
    callback = function()
      Toggle.add_toggle(toggle_opts)
    end,
  })
end

function M.keys()
  -- stylua: ignore
  local builtins = { "zellner", "torte", "slate", "shine", "ron", "quiet", "peachpuff",
  "pablo", "murphy", "lunaperche", "koehler", "industry", "evening", "elflord",
  "desert", "delek", "default", "darkblue", "blue" }

  return {
    {
      "<leader>uu",
      function() -- prevent builtin colors from being displayed in the picker
        local target = vim.fn.getcompletion

        ---@diagnostic disable-next-line: duplicate-set-field
        vim.fn.getcompletion = function()
          return vim.tbl_filter(function(color)
            return not vim.tbl_contains(builtins, color)
          end, target("", "color"))
        end

        require("telescope.builtin").colorscheme({ enable_preview = true })
        vim.fn.getcompletion = target
      end,
      desc = "Colorscheme with preview",
    },
  }
end

return M
