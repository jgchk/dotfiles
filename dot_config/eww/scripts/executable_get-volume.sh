#! /bin/bash

print_vol() {
	volume=$(pamixer --get-volume | cut -d " " -f1)
	muted=$(pamixer --get-mute)
	echo "{\"volume\": $volume, \"muted\": $muted}"
}

print_vol
pactl subscribe |
	grep --line-buffered "Event 'change' on sink " |
	while read -r evt; do
		print_vol
	done
