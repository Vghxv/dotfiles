#!/bin/bash

get_volume() {
  local vol mute
  vol=$(pactl get-sink-volume @DEFAULT_SINK@ | grep -oP '\d+(?=%)' | head -1)
  mute=$(pactl get-sink-mute @DEFAULT_SINK@ | grep -oP '(?<=Mute: )\w+')
  if [[ "$mute" == "yes" ]]; then
    echo "Muted"
  else
    echo "${vol}"
  fi
}

get_volume

pactl subscribe | while read -r line; do
  if echo "$line" | grep -q "sink"; then
    get_volume
  fi
done
