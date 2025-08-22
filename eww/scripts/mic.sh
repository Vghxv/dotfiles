#!/bin/bash

get_volume() {
  local vol mute
  vol=$(pactl get-source-volume @DEFAULT_SOURCE@ | grep -oP '\d+(?=%)' | head -1)
  mute=$(pactl get-source-mute @DEFAULT_SOURCE@ | grep -oP '(?<=Mute: )\w+')
  if [[ "$mute" == "yes" ]]; then
    echo "Muted"
  else
    echo "${vol}"
  fi
}

get_volume

pactl subscribe | while read -r line; do
  if echo "$line" | grep -q "source"; then
    get_volume
  fi
done
