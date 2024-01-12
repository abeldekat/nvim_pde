local function get_keys()
  return {
    {
      "gs",
      function()
        require("substitute").operator()
      end,
      desc = "Substitute operator",
    },
    -- {"gss", function() require("substitute").line() end, desc = "Substitute line"},
    {
      "gs",
      function()
        require("substitute").visual()
      end,
      mode = { "x" },
      desc = "Substitute visual",
    },
    -- no "S" for eol, use dollar

    {
      "gx",
      function()
        require("substitute.exchange").operator()
      end,
      desc = "Exchange operator",
    },
    -- {"gxx", function() require("substitute.exchange").line() end, desc = "Exchange line"},
    {
      "gx",
      function()
        require("substitute.exchange").visual()
      end,
      mode = { "x" },
      desc = "Exchange visual",
    },

    -- Using gm instead of <leader>s.
    -- Mnemonic for now: go more, go multiply as in mini.operators
    -- also uses a register if specified, instead of the prompt
    {
      "gm",
      function()
        require("substitute.range").operator()
      end,
      desc = "Range operator",
    },
    {
      "gmm",
      function()
        require("substitute.range").word()
      end,
      desc = "Range word",
    },
    {
      "gm",
      function()
        require("substitute.range").visual()
      end,
      mode = { "x" },
      desc = "Range visual",
    },
  }
end
return {
  "gbprod/substitute.nvim",
  -- dependencies = {
  --   { -- three superficially unrelated plugins: working with variants of a word.
  --     -- coercion (ie coerce to snake_case) crs --> Adds a cr mapping!
  --     -- abolish iabbrev, subvert substitution
  --     "tpope/vim-abolish",
  --     config = function()
  --       vim.cmd("Abolish {despa,sepe}rat{e,es,ed,ing,ely,ion,ions,or}  {despe,sepa}rat{}")
  --     end,
  --   },
  -- },
  keys = get_keys(),
  config = function()
    require("substitute").setup({ -- range: S fails to substitute using abolish
      highlight_substituted_text = { enabled = false },
    })
  end,
}
