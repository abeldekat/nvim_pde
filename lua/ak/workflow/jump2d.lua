-- Feature request Improve 'mini.jump2d' default config and jumping experience #1818
--
-- Differences leap and jump2d:
-- Equivalence classes
-- Autojump to nearest on two chars. Requires "safe labels", which is inconvenient.
-- Match case-insensitive
-- Labels start from closest match, not top down
-- If many matches, still single chars closeby because of groups(press space).

local use_fork = true

-- akmini.jump2d_leaped is a copy from lua/mini/jump2d.lua,
-- in branch jump2d_extended_character,
-- in fork https://github.com/abeldekat/mini.nivm
local source = use_fork and "akmini.jump2d_leaped" or "mini.jump2d"
local ns_id_dim_all = vim.api.nvim_create_namespace("MiniJump2dDimAll")

require(source).setup({
  allowed_windows = { current = true, not_current = true },
  -- labels = "jklsdewmio", -- 10 labels, without: "a", "f", "g",  "h" and ";"
  --
  -- Have left hand labels grouped around s:
  labels = "jskdlwmeixoc", -- 12 labels alternated "js", "kd", "lw", "me", "ix", "oc"
  --
  mappings = { start_jumping = "" },
  silent = true,
  view = { dim = true, n_steps_ahead = math.huge }, -- not needed for fork
})

local get_allowed_window_ids = function(opts)
  local allowed = (opts or {}).allowed_windows
    or (vim.b.minijump2d_config or {}).allowed_windows
    or MiniJump2d.config.allowed_windows
  local win_id_init = vim.api.nvim_get_current_win()

  return vim.tbl_filter(function(win_id)
    if not vim.api.nvim_win_get_config(win_id).focusable then return false end
    if win_id == win_id_init then return allowed.current end
    return allowed.not_current
  end, vim.api.nvim_tabpage_list_wins(0))
end

local dim_all = function(group, wins)
  for _, win_id in ipairs(wins) do
    local wininfo = vim.fn.getwininfo(win_id)[1]
      -- stylua: ignore
      vim.highlight.range(
        wininfo.bufnr, ns_id_dim_all, group, { wininfo.topline - 1, 0 },
        { wininfo.botline - 1, -1 }, { priority = 9999 }
      )
  end
  vim.cmd("redraw")
end

local undim_all = function(wins)
  for _, win_id in ipairs(wins) do
    pcall(vim.api.nvim_buf_clear_namespace, vim.api.nvim_win_get_buf(win_id), ns_id_dim_all, 0, -1)
  end
end

-- No repeat in operator pending mode... See mini.jump2d, H.apply_config.
local builtin_opts = MiniJump2d.builtin_opts.single_character --[[@as table]]
builtin_opts.view = builtin_opts.view or {}
builtin_opts.view.dim = not use_fork and builtin_opts.view.dim or false
builtin_opts.force_filtering = use_fork

local start = function() return MiniJump2d.start(builtin_opts) end
local start_fork = function()
  local win_id_arr = get_allowed_window_ids()

  dim_all(builtin_opts.hl_group_dim or "MiniJump2dDim", win_id_arr)
  local result = MiniJump2d.start_extended_character(builtin_opts)
  undim_all(win_id_arr)
  return result
end
vim.keymap.set({ "n", "x", "o" }, "s", use_fork and start_fork or start, { desc = "Start 2d jumping" })
