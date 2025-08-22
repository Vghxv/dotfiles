#!/bin/bash

BRIGHTNESS_FILE="/sys/class/backlight/*/brightness"
BRIGHTNESS_FILE=$(echo $BRIGHTNESS_FILE) # expand wildcard
MAX_BRIGHTNESS=19200

get_brightness() {
  local current=$(cat "$BRIGHTNESS_FILE")
  echo $((current * 100 / MAX_BRIGHTNESS))
}

# Initial output
get_brightness

# Listen for file modifications and suppress inotifywait messages
inotifywait -m -e modify "$BRIGHTNESS_FILE" 2>/dev/null | while read; do
  get_brightness
done
