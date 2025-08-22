#!/bin/bash

SOCKET="$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock"

# Get current state
get_state() {
    workspaces=$(hyprctl workspaces -j | jq -c 'map(.id) | sort')
    active=$(hyprctl activeworkspace -j | jq -c '.id')
    echo "{\"workspaces\":$workspaces,\"active\":$active}"
}

# Store last state
last_state=""

# Emit initial state
current_state=$(get_state)
echo "$current_state"
last_state="$current_state"

# Listen for Hyprland events
socat -u UNIX-CONNECT:$SOCKET - | while read -r line; do
    case "$line" in
        workspace* | createworkspace* | destroyworkspace*)
            current_state=$(get_state)
            if [ "$current_state" != "$last_state" ]; then
                echo "$current_state"
                last_state="$current_state"
            fi
            ;;
    esac
done

