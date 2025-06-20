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
local use_leap_hl = false

local setup = function()
  -- akmini.jump2d_leaped is a copy from lua/mini/jump2d.lua,
  -- in branch jump2d_guarantee_second_character,
  -- in my fork https://github.com/abeldekat/mini.nivm
  local source = use_fork and "akmini.jump2d_leaped" or "mini.jump2d"

  require(source).setup({
    allowed_windows = H.allowed_windows,
    -- hl_group = use_leap_hl and "LeapLabel" or nil, --"MiniJump2dSpot",
    -- hl_group_ahead = use_leap_hl and "LeapLabel" or "MiniJump2dSpot", -- "MiniJump2dSpotAhead",
    -- labels = "sdefhjkl;", -- e and r  instead of g and a 10 labels
    labels = "jklsdefmioh", -- 11 labels
    mappings = { start_jumping = "" },
    silent = true,
    view = { n_steps_ahead = 100 },
  })

  -- No repeat in operator pending mode... See mini.jump2d, H.apply_config.
  local modes = { "n", "x", "o" }
  local desc = "Start 2d jumping"
  local start_opts_fn = use_fork and H.start_opts_from_fork or H.start_opts
  local start = H.generate_start(start_opts_fn())
  vim.keymap.set(modes, "s", start, { desc = desc })
end

H.allowed_windows = { current = true, not_current = false }

H.start_opts = function() return MiniJump2d.builtin_opts.single_character end

H.start_opts_from_fork = function() return MiniJump2d.builtin_opts.two_characters end

H.generate_start = function(start_opts)
  local ns_id_dim = vim.api.nvim_create_namespace("MiniJump2dDimImmediately")
  local dim = use_leap_hl and "LeapBackdrop" or "MiniJump2dDim"
  return function()
    H.dim_immediately(ns_id_dim, dim, H.allowed_windows)
    MiniJump2d.start(start_opts)
    H.dim_remove(ns_id_dim, H.allowed_windows)
  end
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
