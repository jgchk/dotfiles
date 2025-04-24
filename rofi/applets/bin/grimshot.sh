#!/usr/bin/env bash

## Author  : Aditya Shakya (adi1090x)
## Github  : @adi1090x
#
## Applets : Screenshot

# Import Current Theme
source "$HOME"/.config/rofi/applets/shared/theme.bash
theme="$type/$style"

# Theme Elements
prompt='Screenshot'
mesg="DIR: $(xdg-user-dir PICTURES)/Screenshots"

# Grimshot Command
grimshot=/usr/share/sway-contrib/grimshot

if [[ "$theme" == *'type-1'* ]]; then
  list_col='1'
  list_row='5'
  win_width='400px'
elif [[ "$theme" == *'type-3'* ]]; then
  list_col='1'
  list_row='5'
  win_width='120px'
elif [[ "$theme" == *'type-5'* ]]; then
  list_col='1'
  list_row='5'
  win_width='520px'
elif [[ ("$theme" == *'type-2'*) || ("$theme" == *'type-4'*) ]]; then
  list_col='5'
  list_row='1'
  win_width='670px'
fi

# Options
layout=$(cat ${theme} | grep 'USE_ICON' | cut -d'=' -f2)
if [[ "$layout" == 'NO' ]]; then
  option_1=" Capture Desktop"
  option_2=" Capture Area"
  option_3=" Capture Window"
  option_4=" Capture in 5s"
  option_5=" Capture in 10s"
  copy="󰅌 Copy to clipboard"
  save="󰠘 Save file"
else
  option_1=""
  option_2=""
  option_3=""
  option_4=""
  option_5=""
  copy="󰅌"
  save="󰠘"
fi

# Rofi CMD
rofi_cmd() {
  rofi -theme-str "window {width: $win_width;}" \
    -theme-str "listview {columns: $list_col; lines: $list_row;}" \
    -theme-str 'textbox-prompt-colon {str: "";}' \
    -dmenu \
    -p "$prompt" \
    -mesg "$mesg" \
    -markup-rows \
    -theme ${theme}
}

# Pass variables to rofi dmenu
run_rofi() {
  echo -e "$option_1\n$option_2\n$option_3\n$option_4\n$option_5" | rofi_cmd
}

mode_cmd() {
  rofi -theme-str "window {width: $win_width;}" \
    -theme-str "listview {columns: $list_col; lines: $list_row;}" \
    -theme-str 'textbox-prompt-colon {str: "";}' \
    -dmenu \
    -p "$prompt" \
    -mesg "$mesg" \
    -markup-rows \
    -theme ${theme}
}

select_mode() {
  echo -e "$copy\n$save" | mode_cmd
}

# Screenshot
time=$(date +%Y-%m-%d-%H-%M-%S)
geometry=$(xrandr | grep 'current' | head -n1 | cut -d',' -f2 | tr -d '[:blank:],current')
dir="$(xdg-user-dir PICTURES)/Screenshots"
file="Screenshot_${time}_${geometry}.png"

if [[ ! -d "$dir" ]]; then
  mkdir -p "$dir"
fi

# notify and view screenshot
notify_view() {
  notify_cmd_shot='dunstify -u low --replace=699'
  if [[ "$mode" == "$copy" ]]; then
    ${notify_cmd_shot} "Copied to clipboard."
  elif [[ "$mode" == "$save" ]]; then
    if [[ -e "$dir/$file" ]]; then
      ${notify_cmd_shot} "Screenshot Saved."
    else
      ${notify_cmd_shot} "Screenshot Deleted."
    fi
    imv ${dir}/"$file"
  fi
}

# Copy screenshot to clipboard
copy_shot() {
  tee "$file" | xclip -selection clipboard -t image/png
}

# countdown
countdown() {
  for sec in $(seq $1 -1 1); do
    dunstify -t 1000 --replace=699 "Taking shot in : $sec"
    sleep 1
  done
}

# take shots
shotnow() {
  cd ${dir}
  sleep 0.5
  if [[ "$mode" == "$copy" ]]; then
    $grimshot copy screen $file
  elif [[ "$mode" == "$save" ]]; then
    $grimshot save screen $file
  fi
  notify_view
}

shot5() {
  countdown '5'
  shotnow
}

shot10() {
  countdown '10'
  shownow
}

shotwin() {
  activewindow=$(hyprctl activewindow)
  at=$(echo "$activewindow" | grep 'at:' | awk '{print $2}')
  size=$(echo "$activewindow" | grep 'size:' | awk '{print $2}')
  formatted="${at} ${size%,*}x${size#*,}"
  if [[ "$mode" == "$copy" ]]; then
    grim -g "$formatted" - | wl-copy --type image/png
  elif [[ "$mode" == "$save" ]]; then
    grim -g "$formatted" "$dir"/"$file"
  fi
  notify_view
}

shotarea() {
  cd ${dir}
  if [[ "$mode" == "$copy" ]]; then
    $grimshot copy area $file
  elif [[ "$mode" == "$save" ]]; then
    $grimshot save area $file
  fi
  notify_view
}

# Execute Command
run_cmd() {
  if [[ "$1" == '--opt1' ]]; then
    shotnow
  elif [[ "$1" == '--opt2' ]]; then
    shotarea
  elif [[ "$1" == '--opt3' ]]; then
    shotwin
  elif [[ "$1" == '--opt4' ]]; then
    shot5
  elif [[ "$1" == '--opt5' ]]; then
    shot10
  fi
}

# Actions
chosen="$(run_rofi)"

# if nothing chosen, exit early
if [[ -z "$chosen" ]]; then
  exit 0
fi

mode="$(select_mode)"

if [[ -z "$mode" ]]; then
  exit 0
fi

case ${chosen} in
$option_1)
  run_cmd --opt1
  ;;
$option_2)
  run_cmd --opt2
  ;;
$option_3)
  run_cmd --opt3
  ;;
$option_4)
  run_cmd --opt4
  ;;
$option_5)
  run_cmd --opt5
  ;;
esac
