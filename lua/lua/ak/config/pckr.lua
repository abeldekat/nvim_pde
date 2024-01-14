--          ╭─────────────────────────────────────────────────────────╮
--          │                      Experimental                       │
--          ╰─────────────────────────────────────────────────────────╯

local function bootstrap_pckr()
  local pckr_path = vim.fn.stdpath("data") .. "/pckr/pckr.nvim"

  if not vim.loop.fs_stat(pckr_path) then
    vim.fn.system({
      "git",
      "clone",
      "--filter=blob:none",
      "https://github.com/lewis6991/pckr.nvim",
      pckr_path,
    })
  end

  vim.opt.rtp:prepend(pckr_path)
end

return function() -- extraspec, opts
  -- local pckr_path = vim.fn.expand("~/projects/lazydev/pckr.nvim")
  -- vim.opt.rtp:prepend(pckr_path)
  bootstrap_pckr()

  local pckr = require("pckr")
  pckr.setup({
    -- package_root = util.join_paths(vim.fn.stdpath("data"), "site", "pack"),
    max_jobs = nil, -- Limit the number of simultaneous jobs. nil means no limit
    autoremove = false, -- Remove unused plugins
    autoinstall = true, -- Auto install plugins
    git = {
      cmd = "git", -- The base command for git operations
      depth = 1, -- Git clone depth
      clone_timeout = 60, -- Timeout, in seconds, for git clones
      default_url_format = "https://github.com/%s", -- Lua format string used for "aaa/bbb" style plugins
    },
    log = { level = "warn" }, -- The default print log level. One of: "trace", "debug", "info", "warn", "error", "fatal".
    -- lockfile = {
    --   path = util.join_paths(vim.fn.stdpath("config", "pckr", "lockfile.lua")),
    -- },
  })
  pckr.add({
    { "nvim-lua/plenary.nvim" },
    {
      "ThePrimeagen/harpoon",
      branch = "harpoon2",
      require = { "nvim-lua/plenary.nvim" },
      config = function()
        require("ak.config.harpoon")
      end,
    },
    {
      "folke/tokyonight.nvim",
      config = function()
        require("tokyonight").setup({})
      end,
    },
  })
end
