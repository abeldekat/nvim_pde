-- https://github.com/golang/tools/tree/master/gopls
-- https://pkg.go.dev/golang.org/x/tools/gopls
-- Arch linux: sudo pacman -S gopls gofumpt
-- Perhaps goimports:
-- https://pkg.go.dev/golang.org/x/tools/cmd/goimports
-- A golang formatter which formats your code in the same style as gofmt and additionally updates your Go import lines,
-- adding missing ones and removing unreferenced ones.

-- gopls in nvim-lspconfig has a root_dir function that is not easy to copy:
return { -- copied from lazyvim:
  settings = {
    gopls = {
      gofumpt = true,
      codelenses = {
        gc_details = false,
        generate = true,
        regenerate_cgo = true,
        run_govulncheck = true,
        test = true,
        tidy = true,
        upgrade_dependency = true,
        vendor = true,
      },
      hints = {
        assignVariableTypes = true,
        compositeLiteralFields = true,
        compositeLiteralTypes = true,
        constantValues = true,
        functionTypeParameters = true,
        parameterNames = true,
        rangeVariableTypes = true,
      },
      analyses = {
        nilness = true,
        unusedparams = true,
        unusedwrite = true,
        useany = true,
      },
      usePlaceholders = true,
      completeUnimported = true,
      staticcheck = true,
      directoryFilters = { "-.git", "-.vscode", "-.idea", "-.vscode-test", "-node_modules" },
      semanticTokens = true,
    },
  },
}
