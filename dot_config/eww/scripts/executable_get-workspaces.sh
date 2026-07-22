#!/usr/bin/env bash

# Emit the JSON eww uses to render the workspace list.
#
# We show only workspaces worth showing: those that currently hold windows,
# plus whichever one is active (so an empty workspace you just switched to
# still appears). Each entry carries:
#   name    - label shown in the bar (letter for named ws, digit for numbered)
#   windows - window count (drives occupied/empty styling)
#   active  - whether this is the focused workspace
#   target  - argument for `hyprctl dispatch workspace` (id for numbered
#             workspaces, name:<X> for named ones)
# Numbered workspaces sort first by value, then named workspaces alphabetically.
generate() {
  local active
  active=$(hyprctl activeworkspace -j | jq '.id')
  hyprctl workspaces -j | jq -c --argjson active "${active}" '
    map(select(.windows > 0 or .id == $active))
    | map({
        name: .name,
        windows: .windows,
        active: (.id == $active),
        target: (if (.name | test("^[0-9]+$")) then (.id | tostring) else "name:\(.name)" end),
        numeric: (.name | test("^[0-9]+$"))
      })
    | sort_by([(if .numeric then 0 else 1 end),
               (if .numeric then (.name | tonumber) else 0 end),
               (.name | ascii_downcase)])
    | map(del(.numeric))
  '
}

# initial state
generate

# re-emit on every Hyprland event (workspace/window changes)
socat -u UNIX-CONNECT:$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock - | while read -r line; do
  generate
done
