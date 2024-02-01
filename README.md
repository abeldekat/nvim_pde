# Neovim pde

My `personal development environment` for `Neovim`

## Design

- `init`: Defer to `ak.init`
- `ak.init`: Start with either [lazy.nvim] or `git submodules`.
- `ak.boot.submodules`: Uses the plugins installed with git submodules.
See [submodules] and the modules in `ak.submodules`.
- `ak.boot.lazy`: Uses [lazy.nvim] to manage plugins, see the modules in `ak.lazy`
- `ak.config`: Invoked by the modules in `ak.boot`

  Contains the setup for:
    1. options
    2. key-mappings
    3. auto-commands
    4. color-schemes
    5. plugins

- `ak.util`: Shared code. Amongst others, contains functions used for lazy-loading

## Install

 > The requirements follow the requirements for [LazyVim](https://www.lazyvim.org/#%EF%B8%8F-requirements)
 >
 > Always review the code before installing a configuration.

Clone the repository and install the plugins:

```sh
git clone https://github.com/abeldekat/nvim_pde ~/.config/ak

# Only when using submodules(the default):
cd ~/.config/ak
git submodule update --init --filter=blob:none --recursive
#
# Build markdown-preview and peek.nvim:
./on_submodule_update
# Now, open Neovim without arguments.
# Treesitter and mason will install.
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

### Boot methods

When testing `lazy.nvim` and `git submodules`,
clone the repo into multiple locations. For example:

- `~/.config/ak`, defaults to `submodules`
- `~/.config/akl`, append AK_BOOT=lazy

Then, use the following alias when booting with `lazy.nvim`:

```sh
alias akl="AK_BOOT=lazy NVIM_APPNAME=akl nvim"
```

### Submodules

Resources:

- `:h packages`
- [medium](https://medium.com/@porteneuve/mastering-git-submodules-34c65e940407)
- [reddit](https://www.reddit.com/r/neovim/comments/15b1gco/what_plugin_manager_are_you_currently_using/)
- [blog](https://hiphish.github.io/blog/2021/12/05/managing-vim-plugins-without-plugin-manager/)

## Performance

Measured by starting the editor without arguments.

Invoke `:StartupTime` or press `<leader>ms`.
Repeat a couple of times.

- submodules: Around 45ms
- [lazy.nvim]: Around 45ms

## Acknowledgements

This repo uses code and ideas from the following repositories:

- [LazyVim](https://github.com/LazyVim/LazyVim)
- [lazy.nvim](https://github.com/folke/lazy.nvim)
- [nvim](https://github.com/echasnovski/nvim) `@echasnovski`
- [dotfiles](https://github.com/folke/dot/tree/master/nvim) `@folke`
- [dotfiles](https://github.com/dpetka2001/dotfiles/tree/main/dot_config/nvim) `@dpetka2001`
- [dotfiles](https://github.com/lewis6991/dotfiles/tree/main/config/nvim) `@lewis6991`
- [dotfiles](https://github.com/savq/dotfiles/tree/master/nvim) `@savq`
- [dotfiles](https://github.com/MariaSolOs/dotfiles/tree/main/.config/nvim) `@mariasolos`
- [pckr.nvim](https://github.com/lewis6991/pckr.nvim)

[lazy.nvim]: https://github.com/folke/lazy.nvim
[submodules]: #submodules
