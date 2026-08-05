# Dotfiles

Managed with [chezmoi](https://www.chezmoi.io/). Source lives at `~/.local/share/chezmoi/`.

## Setting up a new machine

### macOS

```bash
brew install chezmoi
chezmoi init --apply git@github.com:jgchk/dotfiles.git
```

### Arch Linux

```bash
pacman -S chezmoi
chezmoi init --apply git@github.com:jgchk/dotfiles.git
```

You'll be prompted for machine type (`work` or `personal`). After that, all configs are deployed — Linux-only stuff is automatically skipped on macOS and vice versa.

`chezmoi apply` only lays down config **files**. For the programs those configs
depend on and the steps that must be run by hand (SSH key, package installs,
fonts, tmux/nvim plugin bootstrap), follow **[docs/first-setup.md](docs/first-setup.md)**.

## Making changes

### Edit a config directly, then tell chezmoi about it

```bash
# Edit the target file as usual
nvim ~/.config/ghostty/config

# Pull the change into chezmoi's source
chezmoi add ~/.config/ghostty/config

# Commit and push
chezmoi cd
git add -A && git commit -m "update ghostty config"
git push
```

### Edit in chezmoi's source, then apply

```bash
chezmoi edit ~/.config/ghostty/config   # opens the source file in $EDITOR
chezmoi apply                           # deploys changes to target

# Commit and push
chezmoi cd
git add -A && git commit -m "update ghostty config"
git push
```

### Add a new config

```bash
# If the config already exists at its target location:
chezmoi add ~/.config/foo/config.toml

# If it's a whole directory:
chezmoi add ~/.config/foo

# Then commit and push as above
```

### Add a new script

```bash
chezmoi add ~/.local/bin/my-script
# chezmoi will create it as executable_my-script in the source

chezmoi cd
git add -A && git commit -m "add my-script"
git push
```

## Pulling changes from another machine

```bash
chezmoi update
```

This runs `git pull` on the source repo and applies any changes. It's the equivalent of:

```bash
chezmoi cd
git pull
exit
chezmoi apply
```

## Previewing changes before applying

```bash
# See what chezmoi would change
chezmoi diff

# See what files chezmoi manages
chezmoi managed

# Dry-run apply (shows what would happen)
chezmoi apply --dry-run --verbose
```

## Templated files

Some files use Go templates for OS-specific content:

- `~/.config/zsh/.zshenv` — Linux-only env vars (CUDA, GTK, Android SDK)
- `~/.config/zsh/.zshrc` — macOS uses `brew --prefix` for plugin paths, Linux uses `/usr/share/`

To edit these, use `chezmoi edit` so you're working on the template source (`.tmpl` file), not the rendered output. If you edit the target file directly and run `chezmoi add`, it will overwrite the template with a static file.

## OS-conditional files

Defined in `.chezmoiignore`. On macOS, these are skipped entirely:

- Linux desktop: `hypr`, `dunst`, `eww`, `rofi`, `kitty`
- Arch-only scripts: `clean-yay`, `mirrors`, `update`, `record`, `redoflacs`
- `beets`

To add a new OS-conditional config, add it to `.chezmoiignore` under the appropriate `{{ if eq .chezmoi.os "..." }}` block.

## Claude Code skills

Personal Claude Code skills are managed here and deploy to `~/.claude/skills/`:

```bash
# Add a new or edited skill
chezmoi add ~/.claude/skills/<name>/SKILL.md
```

Skills are **universal by default** — they deploy to every machine. For a
machine-specific skill, add its target path to `.chezmoiignore` under the
matching `{{ if eq .machine_type "..." }}` block (machine type is chosen at
`chezmoi init` time), e.g. a work-only skill gets listed under the
`"personal"` block so personal machines skip it:

```
{{ if eq .machine_type "personal" }}
.claude/skills/work-deploy
{{ end }}
```

Note that only the files listed in the source are managed — the rest of
`~/.claude` (settings, projects, plugin caches) stays untouched by chezmoi.
