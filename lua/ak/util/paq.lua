--          ╭─────────────────────────────────────────────────────────╮
--          │             Module containing paq utilities             │
--          ╰─────────────────────────────────────────────────────────╯

---@class ak.util.paq
local M = {}

local lazy_paq = vim.api.nvim_create_augroup("ak_lazy_paq", { clear = true })

function M.on_events(cb, events, pattern)
  local opts = {
    group = lazy_paq,
    desc = "ak_lazy_paq",
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
      return vim.fn.getcompletion(cmd .. " ", "cmdline")
    end,
  })
end

return M
