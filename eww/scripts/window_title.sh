#!/bin/bash

SOCKET="$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock"

get_title() {
  hyprctl activewindow -j | jq -r '.title'
}

last_title=""

current_title=$(get_title)
echo "$current_title"
last_title="$current_title"

socat -u UNIX-CONNECT:$SOCKET - | while read -r line; do
  case "$line" in
  activewindow*)
    current_title=$(get_title)
    if [ "$current_title" != "$last_title" ]; then
      echo "$current_title"
      last_title="$current_title"
    fi
    ;;
  esac
done
