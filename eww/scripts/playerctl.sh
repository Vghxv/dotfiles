PLAYER=$(playerctl -l 2>/dev/null | grep brave | head -n 1)

if [[ -z "$PLAYER" ]]; then
  echo "No player found"
fi

playerctl --follow -p "$PLAYER" metadata --format '{{artist}}|{{title}}' |
  while IFS='|' read -r ARTIST TITLE; do
    STATUS=$(playerctl -p "$PLAYER" status --format '{{ uc(status) }}' 2>/dev/null)
    if [[ "$STATUS" == "STOPPED" ]]; then
      echo "No song playing"
    elif [[ -n "$ARTIST" && -n "$TITLE" ]]; then
      echo "$ARTIST - $TITLE"
    fi
  done
