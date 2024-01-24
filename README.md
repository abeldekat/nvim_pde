# Neovim pde

My `personal development environment` for `Neovim`

## Design

- `init`: Defer to `ak.init`
- `ak.init`: Start with either [paq.nvim] or [lazy.nvim].
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

## Install

 > The requirements follow the requirements for [LazyVim](https://www.lazyvim.org/#%EF%B8%8F-requirements)
 >
 > Always review the code before installing a configuration.

Clone the repository and install the plugins:

```sh
git clone https://github.com/abeldekat/nvim_pde ~/.config/ak
```

Open Neovim with this config:

```sh
NVIM_APPNAME=ak nvim
```

Remove the config:

```sh
rm -rf ~/.local/share/ak ~/.local/state/ak ~/.cache/ak
rm -rf ~/.config/ak
```

## Use

When using both [paq.nvim] and [lazy.nvim], clone the code to two locations:

- `~/.config/ak`
- `~/.config/akl`

Then, use the following alias for `akl`:

```sh
alias akl="AK_BOOT=lazy NVIM_APPNAME=akl nvim"
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
