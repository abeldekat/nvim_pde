-- Visits_harpooned: to add a visit to directory , use <leader>a inside mini.files
-- Discussions/563. Issue 747. Rename file
-- Discussions/1197. Auto bookmakr

local H = {}
local setup = function()
  local config = {
    content = { filter = H.filter_hide }, -- no dotfiles by default
    mappings = { go_in = "L", go_in_plus = "l" }, -- close explorer after opening file with `l`
    windows = { preview = true },
  }
  local minifiles = require("mini.files")
  minifiles.setup(config)
  H.create_autocommmands()

  -- Toggle using keymap `mk` marks the k. Pressing q is good enough though.
  vim.keymap.set("n", "mk", function() -- rolling fingers...
    local buf_path = vim.api.nvim_buf_get_name(0)
    MiniFiles.open(vim.uv.fs_stat(buf_path) ~= nil and buf_path or vim.fn.getcwd())
  end, { desc = "MiniFiles open directory", silent = true })
end

H.create_autocommmands = function()
  local minifiles_augroup = vim.api.nvim_create_augroup("ek-mini-files", {})
  local au = function(pattern, callback)
    vim.api.nvim_create_autocmd("User", { group = minifiles_augroup, pattern = pattern, callback = callback })
  end

  au("MiniFilesExplorerOpen", function() -- bookmarks, alternative is visits_harpooned
    MiniFiles.set_bookmark("c", vim.fn.stdpath("config") .. "", { desc = "Config" })
    MiniFiles.set_bookmark("m", vim.fn.stdpath("data") .. "/site/pack/deps/start/mini.nvim", { desc = "mini.nvim" })
    MiniFiles.set_bookmark("p", vim.fn.stdpath("data") .. "/site/pack/deps/opt", { desc = "Plugins" })
    MiniFiles.set_bookmark("w", vim.fn.getcwd, { desc = "Working directory" })
  end)

  au("MiniFilesBufferCreate", function(args) -- toggle hidden files, map splits
    local b = args.data.buf_id
    vim.keymap.set("n", "g.", H.toggle_dotfiles, { buffer = b })
    vim.keymap.set("n", "g~", H.set_cwd, { buffer = b, desc = "Set cwd" })
    vim.keymap.set("n", "gy", H.yank_path, { buffer = b, desc = "Yank path" })
    vim.keymap.set("n", "<leader>a", H.toggle_path, { buffer = b, desc = "Visits toggle path" })
    H.map_split(b, "<C-s>", "belowright horizontal")
    H.map_split(b, "<C-v>", "belowright vertical")
  end)

  au("MiniFilesWindowUpdate", function(args) -- add linenumbers only to active window
    local win_id = vim.api.nvim_get_current_win()
    if win_id and win_id == args.data.win_id then
      vim.wo[win_id].relativenumber = true
      vim.api.nvim_create_autocmd("WinLeave", {
        once = true,
        callback = function() vim.wo[win_id].relativenumber = false end,
      })
    end
  end)

  -- HACK: Notify LSPs that a file got renamed.
  -- Adapted from snacks.nvim(rename.lua) thanks to MariaSolos
  au("MiniFilesActionRename", function(args)
    local changes = {
      files = {
        {
          oldUri = vim.uri_from_fname(args.data.from),
          newUri = vim.uri_from_fname(args.data.to),
        },
      },
    }
    local will_rename_method, did_rename_method =
      vim.lsp.protocol.Methods.workspace_willRenameFiles, vim.lsp.protocol.Methods.workspace_didRenameFiles
    local clients = vim.lsp.get_clients()
    for _, client in ipairs(clients) do
      if client.supports_method(will_rename_method) then
        local res = client.request_sync(will_rename_method, changes, 1000, 0)
        if res and res.result then vim.lsp.util.apply_workspace_edit(res.result, client.offset_encoding) end
      end
    end
    for _, client in ipairs(clients) do
      if client.supports_method(did_rename_method) then client.notify(did_rename_method, changes) end
    end
  end)
end

H.show_dotfiles = false
H.filter_show = function(_) return true end
H.filter_hide = function(fs_entry) return not vim.startswith(fs_entry.name, ".") end
H.toggle_dotfiles = function()
  H.show_dotfiles = not H.show_dotfiles
  local new_filter = H.show_dotfiles and H.filter_show or H.filter_hide
  MiniFiles.refresh({ content = { filter = new_filter } })
end

H.map_split = function(buf_id, lhs, direction)
  local rhs = function()
    -- Make new window and set it as target
    local cur_target = MiniFiles.get_explorer_state().target_window
    local new_target = vim.api.nvim_win_call(cur_target, function()
      vim.cmd(direction .. " split")
      return vim.api.nvim_get_current_win()
    end)
    MiniFiles.set_target_window(new_target)
    MiniFiles.go_in({ close_on_file = true })
  end
  local desc = "Split " .. direction
  vim.keymap.set("n", lhs, rhs, { buffer = buf_id, desc = desc })
end

H.set_cwd = function() -- set focused directory as current working directory
  local path = (MiniFiles.get_fs_entry() or {}).path
  if path == nil then return vim.notify("Cursor is not on valid entry") end

  vim.fn.chdir(vim.fs.dirname(path))
end

H.yank_path = function() -- yank in register full path of entry under cursor
  local path = (MiniFiles.get_fs_entry() or {}).path
  if path == nil then return vim.notify("Cursor is not on valid entry") end

  vim.fn.setreg(vim.v.register, path)
end

H.toggle_path = function()
  if not VisitsHarpooned then return end
  local path = (MiniFiles.get_fs_entry() or {}).path
  if path == nil then return vim.notify("Cursor is not on valid entry") end

  VisitsHarpooned.toggle(vim.fs.dirname(path))
end

setup()
