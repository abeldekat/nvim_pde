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
  vim.cmd('normal! zv')
end

local on_list = function(args)
  local items = filter_line_locations(args.items)
  if #items > 1 then
    vim.fn.setqflist({}, ' ', { title = 'lsp locations', items = items })
    return vim.cmd('botright copen')
  end
  show_location(items[1])
end

-- Deal with the fact that LuaLS in case of `local a = function()` style
-- treats both `a` and `function()` as definitions of `a`.
local luals_unique_definition = function()
  vim.cmd("normal! m'") -- using ctrl-o and ctrl-i from jumplist, see mini.nvim issue 979

  return vim.lsp.buf.definition({ on_list = on_list })
end

return {
  on_attach = function(client, buf_id)
    -- Reduce very long list of triggers for better 'mini.completion' experience
    client.server_capabilities.completionProvider.triggerCharacters = { '.', ':', '#', '(' }

    -- Override global "Go to source" mapping with dedicated buffer-local
    vim.keymap.set('n', 'gd', luals_unique_definition, { buffer = buf_id, desc = 'goto definition' })
  end,
  settings = {
    Lua = {
      runtime = { version = 'LuaJIT', path = vim.split(package.path, ';') },
      diagnostics = {
        workspacedelay = -1, -- don't make workspace diagnostic, as it consumes too much cpu and ram
      },
      workspace = {
        ignoreSubmodules = true,
        library = { vim.env.VIMRUNTIME },
      },
    },
  },
}
