local Util = require("ak.util")

local mini_snippets, config_path = require("mini.snippets"), vim.fn.stdpath("config")
local lang_patterns = { tex = { "latex.json" }, plaintex = { "latex.json" } }

mini_snippets.setup({
  expand = {
    select = function(snippets, insert)
      if Util.completion == "blink" then -- blink popup covers snippet picker
        require("blink.cmp").cancel() -- cancel uses vim.schedule
        vim.schedule(function() MiniSnippets.default_select(snippets, insert) end)
        return
      end
      MiniSnippets.default_select(snippets, insert)
    end,
  },
  mappings = { jump_next = "", jump_prev = "" }, -- defined in map_multistep
  snippets = {
    mini_snippets.gen_loader.from_file(config_path .. "/snippets/global.json"),
    mini_snippets.gen_loader.from_lang({ lang_patterns = lang_patterns }),
  },
})

MiniKeymap.map_multistep("i", "<C-l>", { "minisnippets_next", "jump_after_tsnode", "jump_after_close" })
MiniKeymap.map_multistep("i", "<C-h>", { "minisnippets_prev", "jump_before_tsnode", "jump_before_open" })

local rhs = function() MiniSnippets.expand({ match = false }) end
vim.keymap.set("i", "<C-g><C-j>", rhs, { desc = "Expand all" })
