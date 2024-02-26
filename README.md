# Neovim pde

My *personal development environment* for Neovim

## Demo

<https://github.com/abeldekat/nvim_pde/assets/58370433/30630481-4b33-44c4-bdb8-825e21144c52>

### Structure

> [!NOTE]
> `git submodules` has been replaced with [mini.deps].
> The config containing `git submodules`
> can be found under the [with_submodules] tag

- `init`: Defers to `ak.init`. Uses `:h vim.loader`.
- `ak.init`: Starts with either [mini.deps] or [lazy.nvim].
- [ak.boot]

    1. `deps`: Uses [mini.deps] and the units in [ak.deps] to boot.
    2. `lazy`: Uses [lazy.nvim] and the units in [ak.lazy] to boot.

- [ak.config]: Contains all setup for options, key-mappings, auto-commands,
color-schemes and plugins.

- [ak.util]: Shared code.

### Grouping

Modules `ak.deps` and `ak.lazy` use the same grouping
for clusters of plugins, making it easy to compare the code.

For example, when configuring the loading of `harpoon`:

- `ak.deps.editor`
- `ak.lazy.editor`

Harpoon's config:

- `ak.config.editor.harpoon`

The plugin can be found in:

- `~/.local/share/ak/site/pack/deps/opt` using [mini.deps]
- `~/.local/share/ak/lazy` using [lazy.nvim]

## Install

 > The requirements follow the requirements for [LazyVim](https://www.lazyvim.org/#%EF%B8%8F-requirements)
 >
 > Always review the code before installing a configuration.

Clone the repository:

```sh
git clone https://github.com/abeldekat/nvim_pde ~/.config/ak
```

Open Neovim with this config, installing the plugins:

```sh
# The default uses [mini.deps].
NVIM_APPNAME=ak nvim
```

Remove the config:

```sh
rm -rf ~/.local/share/ak ~/.local/state/ak ~/.cache/ak
rm -rf ~/.config/ak
```

Note: For [peek.nvim], [deno] needs to be installed.

### Multi boot

The variants in `ak.boot` can be used independently.
Aliases are convenient:

```sh
alias ak="NVIM_APPNAME=ak nvim" # using mini.deps
alias akl="AK_BOOT=lazy NVIM_APPNAME=ak nvim" # using lazy.nvim
```

## Performance

Measured by starting the editor without arguments.

Invoke `:StartupTime` or press `<leader>ms`.
Repeat a couple of times.

- [mini.deps]: Around 45ms
- [lazy.nvim]: Around 46ms

System: `12th Gen Intel(R) Core(TM) i5-1235U` (12 cores), `7.40G` ram

## On lazy loading

**Purpose**:

- Show the code as fast as possible(startup-time)
- Load clusters of plugins on demand(testing, debugging, filetype specific)

Plugins loaded using vim.schedule do not add to the startup-time:

- `VeryLazy`, [lazy.nvim]. Uses `vim.schedule` only after `UIEnter`
- `later()`, [mini.deps]. Uses vim.schedule immediately

Most of the plugins can be loaded this way. Tweaks are sometimes necessary.
For example, `nvim-lspconfig` on `VeryLazy` misses the `FileType` event.
In that case, the solution is to invoke `LspStart` after the setup.

Any code written to make lazy-loading possible *does* add to the startup-time.
For example, consider the [telescope] configuration in `LazyVim`.
The spec defines lots of keys to lazy-load on.
These keys need to be created by [lazy.nvim], adding to the startup-time.

In a **personal** config, as [telescope] is used often,
one can remove all `lazy` keys
and load [telescope] on `VeryLazy`.
This approach has the additional benefit of simplifying the plugin spec.

Neovim **distributions** tend to have multiple specs for the same plugin,
allowing the distribution to be modular. Users can add their own version.
However, those specs need to be merged into one definition,
again adding to the startup-time.

An important question to be answered when lazy-loading:
How often is the plugin needed when opening Neovim?

The [lazy.nvim] part of this config only uses `VeryLazy`, with exceptions.
The [mini.deps] part uses two extra [lazy methods]:

- `on_events`
- `on_keys`

## Workflow

I touch type using the right hand
in combination with the forefinger of the left hand

Leader: `space`

### Navigation

- Main plugins: harpoon, oil and telescope.
- Menu: `mini.clue`

#### Harpoon

- Using the shortcuts for window navigation:
`c-j`, `<c-k>`,`<c-l>`,`<c-h>`, corresponding to file 1-4
- ui: `<leader>j` ("strongest finger")
- add: `<leader>h`

Window navigation:

- `<c-w>hjkl`
- `mw`(next window)
- `me`(last accessed window)

#### Oil

- `ml`("rolling fingers"), opening oil
- `h` up one level
- `l` down one level, open file

#### Tmux

- [tmux-sessionizer] inspired by @ThePrimeagen
- workspaces at the top of the screen,  using [tmuxp]
- leader: `ctrl space`
- navigation:
  - `tmux-sessionizer`: leader h
  - previous session: leader j
  - previous window: leader l
  - existing sessions: leader k
  - switch pane: leader o

### UI

- `mini.statusline`, no colors, except on:
  - mode change
  - diagnostics
  - macro recording
- `cmdheight 0`, no pop-ups
- many color-schemes

Change color-schemes:

- on each startup, see [scripts], `vim_menu_owns`
- telescope, [leader uu], loads all colors, does not show builtin color-schemes
- change the palette of the current color-scheme using [leader a]

Script `vim_menu_owns` writes to `lua.ak.colors`.
Ignoring changes to that file:

```sh
git update-index --assume-unchanged lua/ak/colors.lua
```

## Environment

[tmux](https://github.com/abeldekat/tmux)
[alacritty](https://github.com/abeldekat/alacritty)
[zsh](https://github.com/abeldekat/zsh)
[scripts](https://github.com/abeldekat/scripts)
[awesome](https://github.com/abeldekat/awesome)
[arch linux](https://archlinux.org/)

## Acknowledgements

This repo uses code and ideas from the following repositories:

- [LazyVim](https://github.com/LazyVim/LazyVim)
- [lazy.nvim](https://github.com/folke/lazy.nvim)
- [mini.deps](https://github.com/echasnovski/mini.deps)
- [pckr.nvim](https://github.com/lewis6991/pckr.nvim)
- [nvim](https://github.com/echasnovski/nvim) `@echasnovski`
- [dotfiles](https://github.com/folke/dot/tree/master/nvim) `@folke`
- [dotfiles](https://github.com/dpetka2001/dotfiles/tree/main/dot_config/nvim) `@dpetka2001`
- [dotfiles](https://github.com/lewis6991/dotfiles/tree/main/config/nvim) `@lewis6991`
- [dotfiles](https://github.com/savq/dotfiles/tree/master/nvim) `@savq`
- [dotfiles](https://github.com/MariaSolOs/dotfiles/tree/main/.config/nvim) `@mariasolos`

[lazy.nvim]: https://github.com/folke/lazy.nvim
[mini.deps]: https://github.com/echasnovski/mini.deps
[peek.nvim]: https://github.com/toppair/peek.nvim
[deno]: https://deno.land
[tmuxp]: https://github.com/tmux-python/tmuxp
[scripts]: https://github.com/abeldekat/scripts
[tmux-sessionizer]: https://github.com/abeldekat/scripts/blob/main/tmux-sessionizer
[telescope]: https://github.com/LazyVim/LazyVim/blob/a50f92f7550fb6e9f21c0852e6cb190e6fcd50f5/lua/lazyvim/plugins/editor.lua#L135
[ak.boot]: lua/ak/boot
[ak.deps]: lua/ak/deps
[ak.lazy]: lua/ak/lazy
[ak.config]: lua/ak/config
[ak.util]: lua/ak/util
[leader uu]: lua/ak/util/color.lua
[leader a]: lua/ak/util/color.lua
[lazy methods]: lua/ak/util/defer.lua
[with_submodules]: https://github.com/abeldekat/nvim_pde/tree/with_submodules
