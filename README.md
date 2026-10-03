# dotty

Dotfiles and dev environment setup for macOS (and Ubuntu), managed with [chezmoi](https://chezmoi.io) and [just](https://just.systems).

## Fresh machine setup (macOS)

1. Clone the repo into chezmoi's source directory. On a new Mac, `git` will prompt you to install the Xcode Command Line Tools first.

   ```sh
   git clone https://github.com/gabriella-speariett/dotty ~/.local/share/chezmoi
   ```

2. Run the bootstrap script:

   ```sh
   bash ~/.local/share/chezmoi/setup/bootstrap.sh
   ```

3. Restart your terminal (or open WezTerm).

The bootstrap script:

- installs Homebrew if it's missing
- installs the Nerd Fonts in `setup/fonts/` to `~/Library/Fonts`
- installs chezmoi and applies the dotfiles. It asks once whether this is a work machine, and the answer is saved to `~/.config/chezmoi/chezmoi.toml`.
- points `XDG_CONFIG_HOME` at `~/configuration` by adding a line to `~/.profile` and writing `~/.config/fish/config.fish`. If a different `config.fish` already exists, it's backed up to `config.fish.bak`.
- installs `just` and runs `just install`, which:
  - runs `brew bundle` with `setup/Brewfile`
  - makes fish your login shell (this asks for your password)

Running the bootstrap again is safe.

## Day-to-day usage

Run these from the repo root (`chezmoi cd` takes you there):

| Command           | What it does                                        |
| ----------------- | --------------------------------------------------- |
| `just`            | List available tasks                                |
| `just install`    | Install/update all tools for the current OS         |
| `just update`     | Same as `just install`                              |

Editing dotfiles:

```sh
chezmoi edit ~/configuration/fish/config.fish   # edit the source copy
chezmoi diff                                    # preview changes
chezmoi apply                                   # write changes to ~
chezmoi update                                  # git pull + apply
```

To add a Homebrew package, add it to `setup/Brewfile` and run `just install`.

## Layout

```
configuration/        -> ~/configuration   (XDG_CONFIG_HOME: fish, nvim, git, lazygit, starship, wezterm colours, ...)
dot_wezterm.lua.tmpl  -> ~/.wezterm.lua    (also sets XDG_CONFIG_HOME for shells it launches)
.chezmoi.toml.tmpl    chezmoi config template (asks the "work machine" question)
.chezmoiignore        repo-only files chezmoi should not copy into ~
justfile              setup tasks
setup/
  bootstrap.sh        first-run script (macOS/Linux)
  bootstrap.ps1       first-run script (Windows)
  Brewfile            Homebrew packages and casks
  fonts/              Nerd Fonts (Terminess for the terminal, Fira Mono for code)
  scripts/            per-platform install scripts
```

Files ending in `.tmpl` are chezmoi templates. `configuration/fish/conf.d/private_work.fish.tmpl` only has content on work machines.

## Linux (Ubuntu)

Use the same steps: clone, then run `setup/bootstrap.sh`. `just install` detects Linux and runs `setup/scripts/install-linux.sh` instead of Homebrew. Tools that don't come from apt (neovim, delta, tree-sitter, uv, atuin, starship, zoxide) are installed by [mise](https://mise.jdx.dev) from `configuration/mise/config.toml`; add a line there to install another, and re-run `just update` to upgrade them.
