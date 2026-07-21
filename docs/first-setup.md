# First-time setup — manual steps

`chezmoi apply` lays down the config **files**, but a fresh machine still needs
the underlying programs installed and a few things bootstrapped by hand. This is
the checklist for those steps.

> **Status:** work in progress — grown from real config dependencies. Verify
> package names against your repos (some are AUR) and add anything missing as
> you hit it. Primarily Arch Linux; macOS (Homebrew) equivalents are called out
> where they differ. The desktop (Hyprland) group is Linux-only.

---

## 0. Prerequisites (before `chezmoi init`)

The repo is private and cloned over SSH, so the machine needs a GitHub SSH key
**first**, otherwise `chezmoi init git@github.com:...` fails.

```bash
ssh-keygen -t ed25519 -C "$(hostname)"
cat ~/.ssh/id_ed25519.pub   # add this to https://github.com/settings/keys
ssh -T git@github.com       # confirm access
```

## 1. Bootstrap chezmoi

```bash
sudo pacman -S chezmoi
chezmoi init --apply git@github.com:jgchk/dotfiles.git   # prompts: machine type (work/personal)
```

See [../README.md](../README.md) for the day-to-day chezmoi workflow.

---

## 2. Install packages

Grouped by area. Install what you need for this machine (a headless/work box can
skip the whole Hyprland desktop group).

### Shell + CLI core

```bash
sudo pacman -S zsh tmux starship zoxide fzf jujutsu lazygit \
               zsh-autosuggestions zsh-syntax-highlighting pkgfile
```

- `zsh-autosuggestions` / `zsh-syntax-highlighting` — sourced from
  `/usr/share/zsh/plugins/...` in `.zshrc`.
- `pkgfile` — provides `command-not-found`; **run `sudo pkgfile --update` once**
  (see §3).
- `jujutsu` provides the `jj` binary (shell completions are wired up in `.zshrc`).
- Set zsh as the login shell if it isn't: `chsh -s $(which zsh)`.

### Node runtime

```bash
sudo pacman -S fnm          # Arch — Node version manager (`.zshrc` runs `fnm env`)
# macOS:  brew install fnm
fnm install --lts
```

### Neovim tooling — LSP servers, formatter, treesitter parsers

nvim expects these binaries on `PATH`. **Prefer your system package manager over
`npm i -g`** — npm global installs live inside the *active* fnm Node version's
directory and silently disappear the next time fnm switches versions, which shows
up as `language server ... not installed` or `no such command tree-sitter` errors.

| Tool | Binary | Arch | macOS |
|------|--------|------|-------|
| TypeScript LSP | `vtsls` | `yay -S vtsls` (AUR) | `npm i -g @vtsls/language-server` |
| ESLint / JSON / HTML / CSS LSP | `vscode-eslint-language-server` | `yay -S vscode-langservers-extracted` (AUR) | `npm i -g vscode-langservers-extracted` |
| Formatter | `prettier` | `sudo pacman -S prettier` | `brew install prettier` |
| Treesitter parser compiler | `tree-sitter` | `sudo pacman -S tree-sitter-cli` | `brew install tree-sitter` |

- `vtsls` / `eslint` are the servers enabled in `nvim/lua/config/lsp.lua`.
- `prettier` → used by conform.nvim for formatting.
- `tree-sitter` (CLI) compiles the parsers listed in
  `nvim/lua/plugins/treesitter.lua` — nvim-treesitter's `main` branch builds them
  from source on `:TSUpdate` / first launch.
- `vtsls` and `vscode-langservers-extracted` have no Homebrew formula, so macOS
  falls back to npm for those two. If you use npm, run `fnm default <version>` and
  reinstall after any Node upgrade so the globals don't vanish.

### Editor

```bash
sudo pacman -S neovim        # Arch — needs vim.pack (Neovim ≥ 0.12 / nightly)
# macOS:  brew install neovim
```

Plugins auto-install on first `nvim` launch (native `vim.pack`). See §4.

### Hyprland desktop (skip on servers / macOS)

```bash
# official repos
sudo pacman -S hyprland hyprpaper hyprsunset wl-clipboard cliphist polkit-gnome \
               udiskie rofi dunst kitty

# AUR (via yay) — verify names, these move around
yay -S eww swaync
```

`hyprsunset` is the blue-light filter (schedule in `hypr/hyprsunset.conf`); it
replaced `hyprshade`.

Autostarted by `hypr/configs/exec.conf`: `polkit-gnome`, `hyprpaper`,
`hyprsunset`, `wl-paste`/`cliphist`, `swaync`, `udiskie`, `eww`.

### Misc apps (optional, only if you use them)

```bash
sudo pacman -S beets zellij       # music tagger, terminal multiplexer
# vscode: install 'code'/'visual-studio-code-bin' separately if wanted
```

---

## 3. Post-install bootstrapping

### command-not-found database

```bash
sudo pkgfile --update
```

### Fonts — BerkeleyMono Nerd Font (ghostty/starship glyphs)

The original (paid) Berkeley Mono TTFs are vendored in the repo under
`.fonts-src/berkeleymono/`. A helper patches them into
`BerkeleyMono Nerd Font Mono` and installs them:

```bash
sudo pacman -S fontforge      # patcher dependency
patch-berkeleymono            # deployed to ~/.local/bin by chezmoi
```

### tmux — plugins (automated)

Nothing to do by hand. A chezmoi `run_onchange_` script
(`.chezmoiscripts/run_onchange_after_install-tmux-plugins.sh.tmpl`) clones TPM to
`~/.tmux/plugins/tpm` and runs `install_plugins` non-interactively.

It runs on `chezmoi apply` and re-runs automatically when either the plugin list
in `tmux.conf` changes **or** tmux first becomes available. So if you installed
tmux (§2) *after* the initial `chezmoi init`, just run `chezmoi apply` once more
and the plugins install themselves — no `prefix + I` needed.

### Neovim — first launch

Just run `nvim`. `vim.pack` downloads and installs plugins on startup; quit and
reopen once it finishes. Treesitter parsers compile on demand — this needs the
`tree-sitter` CLI (see §2) **and** a C compiler (`base-devel` on Arch, Xcode
Command Line Tools / `xcode-select --install` on macOS).

---

## 4. Verify

```bash
exec zsh                                   # no startup errors
starship --version && zoxide --version     # prompt tools present
fc-match "BerkeleyMono Nerd Font Mono"     # -> BerkeleyMonoNerdFontMono-Regular.ttf
tmux new -d && tmux list-plugins; tmux kill-server   # TPM plugins loaded
nvim +checkhealth                          # nvim + LSP/tools
```

Then restart the terminal (and re-login to Hyprland on a desktop) so the font
and autostart stack come up cleanly.
