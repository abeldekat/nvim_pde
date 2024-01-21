# Neovim pde

My `personal development environment` for `Neovim`

## Design

- `init`: Defer to `ak.init`
- `ak.init`: Start with either [paq.nvim] or [lazy.nvim].
 The latter is chosen when environment variable `USE_LAZY` is present
- `ak.boot.paq`: Uses [paq.nvim] to lazy-load plugins, see the modules in `ak.paq`
- `ak.boot.lazy`: Uses [lazy.nvim] to lazy-load plugins, see the modules in `ak.lazy`
- `ak.config`: Invoked by the modules in either `ak.paq` or `ak.lazy`
  Contains the setup for:
    1. plugins
    2. options
    3. key-mappings
    4. auto-commands
    5. color-schemes
- `ak.util`: Shared code.

## Use

When using both [paq.nvim] and [lazy.nvim], clone the code to two locations:

- `~/.config/nvim`
- `~/.config/nviml`

Then, use the following alias for `nviml`:

```sh
alias nviml="USE_LAZY=true NVIM_APPNAME=nviml nvim"
```

## Performance

Measured by starting the editor without arguments.

Invoke `:StartupTime` or press `<leader>ms`.
Repeat a couple of times.

- [lazy.nvim]: Around 50ms
- [paq.nvim]: Around 60ms

## Acknowledgments

This repo uses code and ideas from the following repositories:

- [LazyVim](https://github.com/LazyVim/LazyVim)
- [lazy.nvim](https://github.com/folke/lazy.nvim)
- [dotfiles](https://github.com/folke/dot/tree/master/nvim) `@folke`
- [dotfiles](https://github.com/dpetka2001/dotfiles/tree/main/dot_config/nvim) `@dpetka2001`
- [dotfiles](https://github.com/lewis6991/dotfiles/tree/main/config/nvim) `@lewis6991`
- [dotfiles](https://github.com/savq/dotfiles/tree/master/nvim) `@savq`
- [dotfiles](https://github.com/MariaSolOs/dotfiles/tree/main/.config/nvim) `@mariasolos`
- [pckr.nvim](https://github.com/lewis6991/pckr.nvim)

[paq.nvim]: https://github.com/savq/paq-nvim
[lazy.nvim]: https://github.com/folke/lazy.nvim
