-- assumption: .luarc.jsonc takes precendence. individual values override,
-- arrays are not merged
-- example: diagnostics global array, "one" in lua_ls settings,
-- and "two" in .luarc.json -> only a warning on global "one"
-- note: when uncommenting a library block in .luarc.jsonc, the completion
-- becomes available without restarting nvim

-- luals "go to source" =======================================================
-- deal with the fact that luals in case of `local a = function()` style
-- treats both `a` and `function()` as definitions of `a`.
-- do this by tweaking `vim.lsp.buf_definition` mapping as client-local
-- handlers are ignored after https://github.com/neovim/neovim/pull/30877
local filter_line_locations = function(locations)
  local present, res = {}, {}
  for _, l in ipairs(locations) do
    local t = present[l.filename] or {}
    if not t[l.lnum] then
      table.insert(res, l)
      t[l.lnum] = true
    end
    present[l.filename] = t
  end
  return res
end

local show_location = function(location)
  local buf_id = location.bufnr or vim.fn.bufadd(location.filename)
  vim.bo[buf_id].buflisted = true
  vim.api.nvim_win_set_buf(0, buf_id)
  vim.api.nvim_win_set_cursor(0, { location.lnum, location.col - 1 })
  vim.cmd("normal! zv")
end

local on_list = function(args)
  local items = filter_line_locations(args.items)
  if #items > 1 then
    vim.fn.setqflist({}, " ", { title = "lsp locations", items = items })
    return vim.cmd("botright copen")
  end
  show_location(items[1])
end

local luals_unique_definition = function()
  -- using ctrl-o and ctrl-i from jumplist:
  vim.cmd("normal! m'") -- see mini.nvim issue 979, and ak.config.editor.mini_pick.lua

  return vim.lsp.buf.definition({ on_list = on_list })
end

return {
  on_attach = function(client, bufnr)
    -- reduce unnecessarily long list of completion triggers for better 'mini.completion' experience
    client.server_capabilities.completionProvider.triggerCharacters = { ".", ":" }
    vim.keymap.set("n", "gd", luals_unique_definition, { buffer = bufnr, desc = "goto definition" })
  end,
  settings = {
    lua = {
      runtime = { version = "luajit", path = vim.split(package.path, ";") },
      diagnostics = {
        -- get the language server to recognize common globals
        globals = { "vim", "describe", "it", "before_each", "after_each" },
        -- disable = { "need-check-nil" },
        -- don't make workspace diagnostic, as it consumes too much cpu and ram
        workspacedelay = -1,
      },
      telemetry = { enable = false },
    },
  },
}
