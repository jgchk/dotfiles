#!/usr/bin/env bash
#
# Scroll handler for the eww workspace widget. Cycles through the workspaces
# that currently exist (numbered and named alike) using Hyprland's relative
# e+1 / e-1 dispatch, so there is no fixed range to clamp to.

direction=$1
if [ "$direction" = "down" ]; then
  hyprctl dispatch workspace e+1
elif [ "$direction" = "up" ]; then
  hyprctl dispatch workspace e-1
fi
