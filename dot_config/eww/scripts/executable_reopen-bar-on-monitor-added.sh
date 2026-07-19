#!/usr/bin/env bash

# DP monitors fully disconnect from DRM when they sleep, which destroys the
# eww window; eww never reopens it on its own. Watch Hyprland's event socket
# and reopen the bar whenever a monitor comes back.
socat -u UNIX-CONNECT:$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock - | while read -r line; do
  case $line in
  monitoradded*)
    sleep 1 # let the compositor finish bringing the output up
    eww open bar_1
    ;;
  esac
done
