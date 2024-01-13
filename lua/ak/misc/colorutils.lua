local M = {}

function M.add_toggle(pattern, toggle_opts)
  vim.api.nvim_create_autocmd("ColorScheme", {
    pattern = type(pattern) == string and { pattern } or pattern,
    callback = function()
      require("ak.misc.colortoggle").add_toggle(toggle_opts)
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

        -- TODO: lazyvim.util
        require("ak.util").telescope("colorscheme", { enable_preview = true })()
        vim.fn.getcompletion = target
      end,
      desc = "Colorscheme with preview",
    },
  }
end

return M
