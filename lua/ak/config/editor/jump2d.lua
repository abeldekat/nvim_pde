-- Feature request Improve 'mini.jump2d' default config and jumping experience #1818
--
-- Difference: loss of leap's autojump to nearest on two chars. Requires "safe labels"
-- Difference: match not case-insensite
-- Difference: the labels don't start from the closest match, but top down

local user_input_opts = function(input_fun) -- copied
  local res = {
    spotter = function() return {} end,
    allowed_lines = { blank = false, fold = false },
  }

  local before_start = function()
    local input = input_fun()
    -- Allow user to cancel input and not show any jumping spots
    if input == nil then return end
    res.spotter = MiniJump2d.gen_spotter.pattern(vim.pesc(input))
  end
  res.hooks = { before_start = before_start }
  return res
end

local getcharstr = function() -- copied H.getcharstr and modified
  local _, char = pcall(vim.fn.getcharstr)
  return char
end

require("mini.jump2d").setup({
  -- character spotter defaults to blank = false: -- type j/k after the jump, or use paragraph motions...
  allowed_lines = { cursor_at = false }, -- use fFtT on current line.
  labels = "jkl;miosde",
  mappings = { start_jumping = "" },
  silent = true,
  view = { dim = true, n_steps_ahead = 1 },
})

-- See MiniJump2d.builtin_opts.single_character:
local double_character = user_input_opts(function() return getcharstr() .. getcharstr() end)

-- No repeat in operator pending mode... See mini.jump2d H.apply_config.
local modes = { "n", "x", "o" }
local desc = "Start 2d jumping"
vim.keymap.set(modes, "s", function() MiniJump2d.start(double_character) end, { desc = desc })
