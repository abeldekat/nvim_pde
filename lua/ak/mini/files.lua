-- Discussions/563. Issue 747. Rename file
-- Discussions/1197. Auto bookmarks

local H = {}
local setup = function()
  local config = {
    content = { filter = H.filter_show },
    mappings = { go_in = "L", go_in_plus = "l" }, -- close explorer after opening file with `l`

    windows = { max_number = H.max_windows, preview = H.can_preview() },
  }
  local minifiles = require("mini.files")
  minifiles.setup(config)
  H.create_autocommmands()
end

H.create_autocommmands = function()
  local add_marks = function()
    MiniFiles.set_bookmark("c", vim.fn.stdpath("config") .. "", { desc = "Config" })
    MiniFiles.set_bookmark("p", vim.fn.stdpath("data") .. "/site/pack/deps/opt", { desc = "Plugins" })
    MiniFiles.set_bookmark("w", vim.fn.getcwd, { desc = "Working directory" })
  end
  _G.Config.new_autocmd("User", "MiniFilesExplorerOpen", add_marks, "Add bookmarks")

  local extra_keys = function(args)
    local b = args.data.buf_id

    vim.keymap.set("n", "g.", H.toggle_dotfiles, { buffer = b })
    vim.keymap.set("n", "g~", H.set_cwd, { buffer = b, desc = "Set cwd" })
    vim.keymap.set("n", "gm", H.toggle_max_windows, { buffer = b, desc = "Toggle max windows" })
    vim.keymap.set("n", "gy", H.yank_path, { buffer = b, desc = "Yank path" })
    H.map_split(b, "<C-s>", "belowright horizontal")
    H.map_split(b, "<C-v>", "belowright vertical")

    -- split keyboard with miryoku layout and vim layer:
    vim.keymap.set("n", "<Right>", "l", { buffer = b, remap = true })
    vim.keymap.set("n", "<Left>", "h", { buffer = b, remap = true })
  end
  _G.Config.new_autocmd("User", "MiniFilesBufferCreate", extra_keys, "Add extra keys")

  local restrict_linenumbers = function(args) -- add linenumbers only to active window
    local win_id = vim.api.nvim_get_current_win()
    if win_id and win_id == args.data.win_id then
      vim.wo[win_id].relativenumber = true
      vim.api.nvim_create_autocmd("WinLeave", {
        once = true,
        callback = function() vim.wo[win_id].relativenumber = false end,
      })
    end
  end
  _G.Config.new_autocmd("User", "MiniFilesWindowUpdate", restrict_linenumbers, "Restrict linenumbers")

  -- HACK: Notify LSPs that a file got renamed.
  -- Adapted from snacks.nvim(rename.lua) thanks to MariaSolos
  local file_rename = function(args)
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
      if client:supports_method(will_rename_method) then
        local res = client:request_sync(will_rename_method, changes, 1000, 0)
        if res and res.result then vim.lsp.util.apply_workspace_edit(res.result, client.offset_encoding) end
      end
    end
    for _, client in ipairs(clients) do
      if client:supports_method(did_rename_method) then client:notify(did_rename_method, changes) end
    end
  end
  _G.Config.new_autocmd("User", "MiniFilesActionRename", file_rename, "File rename")
  _G.Config.new_autocmd("User", "MiniFilesActionMove", file_rename, "File rename")
end

H.show_dotfiles = true
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

H.toggle_max_windows = function()
  H.max_windows = H.max_windows == H.min_windows and math.huge or H.min_windows
  MiniFiles.refresh({ windows = { max_number = H.max_windows, preview = H.can_preview() } })
end

H.can_preview = function() return H.max_windows > 1 end

H.min_windows = 2
H.max_windows = math.huge -- H.min_windows

setup()
