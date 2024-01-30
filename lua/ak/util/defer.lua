--          ╭─────────────────────────────────────────────────────────╮
--          │  Module containing functions to defer loading a plugin  │
--          ╰─────────────────────────────────────────────────────────╯

---@class ak.util.defer
local M = {}

local defer_group = vim.api.nvim_create_augroup("ak_defer", { clear = true })

function M.on_events(cb, events, pattern)
  local opts = {
    group = defer_group,
    desc = "ak_defer",
    once = true,
    callback = function(ev)
      cb(ev)
    end,
  }
  if pattern then
    opts["pattern"] = pattern
  end
  vim.api.nvim_create_autocmd(events, opts)
end

function M.on_keys(cb, keys, desc)
  keys = type(keys) == "string" and { keys } or keys
  for _, key in ipairs(keys) do
    vim.keymap.set("n", key, function()
      vim.keymap.del("n", key)
      cb()
      vim.api.nvim_input(vim.api.nvim_replace_termcodes(key, true, true, true))
    end, { desc = desc, silent = true })
  end
end

function M.on_command(cb, cmd) -- pckr.nvim, pckr.loader.cmd
  vim.api.nvim_create_user_command(cmd, function(args)
    vim.api.nvim_del_user_command(cmd)
    cb()
    vim.cmd(
      string.format(
        "%s %s%s%s %s",
        args.mods or "",
        args.line1 == args.line2 and "" or args.line1 .. "," .. args.line2,
        cmd,
        args.bang and "!" or "",
        args.args
      )
    )
  end, {
    bang = true,
    nargs = "*",
    complete = function()
      vim.api.nvim_del_user_command(cmd)
      cb()
      ---@diagnostic disable-next-line: redundant-parameter
      return vim.fn.getcompletion(cmd .. " ", "cmdline")
    end,
  })
end

--          ╭─────────────────────────────────────────────────────────╮
--          │             Copied code from echasnovski                \
--          ╰─────────────────────────────────────────────────────────╯

local H = {}

-- Various cache
H.cache = {
  -- Whether finish of `later()` is already scheduled
  finish_is_scheduled = false,

  -- Callback queue for `later()`
  later_callback_queue = {},

  -- Errors during execution of `later()`
  exec_errors = {},
}

-- TODO: exec-errors
M.later = function(f)
  table.insert(H.cache.later_callback_queue, f)
  H.schedule_finish()
end

H.now = function(f)
  local ok, err = pcall(f)
  if not ok then
    table.insert(H.cache.exec_errors, err)
  end
  H.schedule_finish()
end

H.schedule_finish = function()
  if H.cache.finish_is_scheduled then
    return
  end
  vim.schedule(H.finish)
  H.cache.finish_is_scheduled = true
end

H.finish = function()
  local timer, step_delay = vim.loop.new_timer(), 1
  local f = nil
  f = vim.schedule_wrap(function()
    local callback = H.cache.later_callback_queue[1]
    if callback == nil then
      H.cache.finish_is_scheduled, H.cache.later_callback_queue = false, {}
      -- H.report_errors()
      return
    end

    table.remove(H.cache.later_callback_queue, 1)

    H.now(callback)

    timer:start(step_delay, 0, f)
  end)
  timer:start(step_delay, 0, f)
end

return M
