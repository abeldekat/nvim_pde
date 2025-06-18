-- Feature request Improve 'mini.jump2d' default config and jumping experience #1818
--
-- Differences leap and jump2d:
-- Equivalence classes
-- Autojump to nearest on two chars. Requires "safe labels", which is inconvenient.
-- Match case-insensitive
-- Labels start from closest match, not top down
-- If many matches, still single chars closeby because of groups(press space).

local H = {}
local use_fork = true

local setup = function()
  -- akmini.jump2d_leaped is a copy from lua/mini/jump2d.lua,
  -- in branch jump2d_include_second_character_refactored,
  -- in my fork https://github.com/abeldekat/mini.nivm
  local source = use_fork and "akmini.jump2d_leaped" or "mini.jump2d"
  local start = use_fork and H.start_fork or H.start

  require(source).setup({
    allowed_windows = H.allowed_windows,
    hl_group = use_fork and "LeapLabel" or nil,
    hl_group_ahead = use_fork and "LeapLabel" or nil,
    labels = "jkl;mhniosde",
    mappings = { start_jumping = "" },
    silent = true,
    view = { dim = not use_fork and true or false, n_steps_ahead = 100 },
  })

  -- No repeat in operator pending mode... See mini.jump2d, H.apply_config.
  local modes = { "n", "x", "o" }
  local desc = "Start 2d jumping"
  vim.keymap.set(modes, "s", start, { desc = desc })
end

H.allowed_windows = { current = true, not_current = true }
H.ns_id_dim = vim.api.nvim_create_namespace("MiniJump2dDimImmediately")

H.start = function() MiniJump2d.start(MiniJump2d.builtin_opts.single_character) end

H.start_fork = function()
  H.dim_immediately(H.ns_id_dim, "LeapBackdrop", H.allowed_windows)
  MiniJump2d.start(MiniJump2d.builtin_opts.single_character_extended) -- NOTE: New builtin
  H.dim_remove(H.ns_id_dim, H.allowed_windows)
end

H.dim_immediately = function(ns, group, allowed_windows)
  for _, win_id in ipairs(H.list_wins(allowed_windows)) do
    local wininfo = vim.fn.getwininfo(win_id)[1]
    --stylua: ignore
    vim.highlight.range(
      wininfo.bufnr, ns, group,
      { wininfo.topline - 1, 0 }, { wininfo.botline - 1, -1 }, { priority = 9999 }
    )
  end
  vim.cmd("redraw")
end

H.dim_remove = function(ns, allowed_windows)
  for _, win_id in ipairs(H.list_wins(allowed_windows)) do
    pcall(vim.api.nvim_buf_clear_namespace, vim.api.nvim_win_get_buf(win_id), ns, 0, -1)
  end
end

H.list_wins = function(allowed_windows)
  local win_id_init = vim.api.nvim_get_current_win()
  return vim.tbl_filter(function(win_id)
    if win_id == win_id_init then return allowed_windows.current end
    return allowed_windows.not_current
  end, vim.api.nvim_list_wins())
end

setup()
