-- https://github.com/bash-lsp/bash-language-server
-- Using mason. Arch linux: sudo pacman -S bash-language-server
-- Mason name: bash-language-server. Nvim-lspconfig name: bash_ls
return {
  cmd = { "bash-language-server", "start" },
  settings = {
    bashIde = {
      -- Glob pattern for finding and parsing shell script files in the workspace.
      -- Used by the background analysis features across files.

      -- Prevent recursive scanning which will cause issues when opening a file
      -- directly in the home directory (e.g. ~/foo.sh).
      --
      -- Default upstream pattern is "**/*@(.sh|.inc|.bash|.command)".
      globPattern = vim.env.GLOB_PATTERN or "*@(.sh|.inc|.bash|.command)",
    },
  },
  filetypes = { "zsh", "bash", "sh" }, -- added zsh
}
