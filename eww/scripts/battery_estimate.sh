#!/usr/bin/env bash
BAT="/sys/class/power_supply/BAT0"

read_file() {
  local f="$1"
  [[ -f "$f" ]] && cat "$f" || echo 0
}

status=$(read_file "$BAT/status")

now=$(read_file "$BAT/energy_now")
full=$(read_file "$BAT/energy_full")
rate=$(read_file "$BAT/power_now")

# fallback if energy_* doesn't exist
if [[ "$now" == "0" || "$rate" == "0" ]]; then
  now=$(read_file "$BAT/charge_now")
  full=$(read_file "$BAT/charge_full")
  rate=$(read_file "$BAT/current_now")
fi

if [[ "$rate" -le 0 ]]; then
  echo "Eternity"
  exit 0
fi

if [[ "$status" == "Discharging" ]]; then
  awk -v n="$now" -v r="$rate" '
    BEGIN {
        t = (n / r) * 3600;
        h = int(t / 3600);
        m = int((t % 3600) / 60);
        printf "Depleted in - %dh:%02dm\n", h, m;
    }'
elif [[ "$status" == "Charging" ]]; then
  awk -v n="$now" -v f="$full" -v r="$rate" '
    BEGIN {
        t = ((f - n) / r) * 3600;
        h = int(t / 3600);
        m = int((t % 3600) / 60);
        printf "Fully Charged in - %dh:%02dm\n", h, m;
    }'
else
  echo "What happend? $now $full $rate"
fi
