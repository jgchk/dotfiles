# First-time setup — manual steps

`chezmoi apply` lays down the config **files**, but a fresh machine still needs
the underlying programs installed and a few things bootstrapped by hand. This is
the checklist for those steps.

> **Status:** work in progress — grown from real config dependencies. Verify
> package names against your repos (some are AUR) and add anything missing as
> you hit it. Arch Linux focused.

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

### Node toolchain (needed by nvim LSP + some CLIs)

```bash
sudo pacman -S fnm          # Node version manager (`.zshrc` runs `fnm env`)
fnm install --lts
npm i -g @vtsls/language-server vscode-langservers-extracted prettier
```

- `@vtsls/language-server` → `vtsls` (TypeScript LSP used by nvim).
- `vscode-langservers-extracted` → `eslint` language server.
- `prettier` → used by conform.nvim for formatting.

### Editor

```bash
sudo pacman -S neovim        # needs a version with vim.pack (Neovim ≥ 0.12 / nightly)
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
reopen once it finishes. Treesitter parsers compile on demand (needs a C
compiler — `base-devel`).

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
