# Path
typeset -U path PATH
path=(~/.local/bin $path)
export PATH

# XDG
export XDG_CONFIG_HOME=$HOME/.config
export XDG_CACHE_HOME=$HOME/.cache
export XDG_DATA_HOME=$HOME/.local/share
export XDG_STATE_HOME=$HOME/.local/state

# Rust
export RUSTUP_HOME="$XDG_DATA_HOME"/rustup
export CARGO_HOME="$XDG_DATA_HOME"/cargo

# CUDA
export CUDA_CACHE_PATH="$XDG_CACHE_HOME"/nv

# NPM
export NPM_CONFIG_USERCONFIG=$XDG_CONFIG_HOME/npm/npmrc

# GTK
export GTK2_RC_FILES="$XDG_CONFIG_HOME"/gtk-2.0/gtkrc

# Postgres
export PSQL_HISTORY="$XDG_DATA_HOME/psql_history"

# Docker
export DOCKER_CONFIG="$XDG_CONFIG_HOME"/docker

# Use Pulse for OpenAL (Minecraft audio)
export ALSOFT_DRIVERS=pulse

# Android Studio
export ANDROID_HOME="$XDG_DATA_HOME"/android

# GnuPG
export GNUPGHOME="$XDG_DATA_HOME"/gnupg
