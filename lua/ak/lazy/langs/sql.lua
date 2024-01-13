-- dadbod-ui and mysql: ft hardcoded to "mysql", breaking treesitter and comment
-- use dadbod for autocompletion, combine with vim-slime and mysql cli
-- in .envrc construct $DATABASE_URL
-- or in .lazy.lua: w:db b:db g:db
return {
  "tpope/vim-dadbod",
  keys = function() -- trigger using keys when ft = sql
    local function send_paragraph()
      vim.cmd('norm! "xyip')
      vim.cmd("silent! DB " .. vim.fn.getreg("x")) -- <cmd>silent! %DB<cr>
    end
    return {
      -- execute a query without vim-slime and the mysql cli:
      { "mq", send_paragraph, ft = "sql", desc = "Run sql in paragraph" },
        -- stylua: ignore
        { "<leader>md", function() vim.print("Loaded dadbod") end, ft = "sql", desc = "Load dadbod" },
    }
  end,
  dependencies = { "kristijanhusak/vim-dadbod-completion" },
  config = function()
    local function cmp()
      require("cmp").setup.buffer({ sources = { { name = "vim-dadbod-completion" } } })
    end
    vim.api.nvim_create_autocmd("FileType", {
      pattern = { "sql" },
      callback = cmp,
    })

    vim.cmd("DBCompletionClearCache") -- current buffer completion
    cmp()
  end,
}
