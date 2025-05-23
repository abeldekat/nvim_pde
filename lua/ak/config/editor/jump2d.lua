-- Feature request Improve 'mini.jump2d' default config and jumping experience #1818
-- minor: loss of leap's autojump to nearest on two chars. Requires "safe labels"
-- minor: match not case-insensite
-- inconvenient: the labels don't start from the closest match, but top down

local user_input_opts = function(input_fun) -- Copied
  local res = {
    spotter = function() return {} end,
    allowed_lines = { blank = false, fold = false },
  }

  res.hooks = {
    before_start = function()
      local input = input_fun()
      if input ~= nil then res.spotter = MiniJump2d.gen_spotter.pattern(vim.pesc(input)) end
    end,
  }
  return res
end

local getleapedstr = function(msg) -- gets two chars
  local _, char1 = pcall(vim.fn.getcharstr)
  local _, char2 = pcall(vim.fn.getcharstr)
  return char1 .. char2
end

require("mini.jump2d").setup({
  allowed_lines = {
    blank = false, -- type j/k after the jump, or use paragraph motions...
    cursor_at = false, -- use fFtT on current line.
  },
  allowed_windows = { not_current = false }, -- I don't work with split windows that much
  labels = "jkl;miosde",
  mappings = { start_jumping = "" },
  silent = true,
  view = { dim = true, n_steps_ahead = 1 },
})

local start = function() -- two chars, based on MiniJump2d.builtin_opts.single_character
  local leaped_table = user_input_opts(function() return getleapedstr() end)
  MiniJump2d.start(leaped_table)
end

-- No repeat in operator pending mode... See mini.jump2d H.apply_config.
vim.keymap.set({ "n", "x", "o" }, "s", start, { desc = "Start 2d jumping" })
