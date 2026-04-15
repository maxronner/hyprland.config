#!/bin/sh

timeout=${1:-2000}
timeout_secs=$((timeout / 1000))
STATE_FILE="$XDG_RUNTIME_DIR/hypr-hide-cursor"

if [ -f "$STATE_FILE" ]; then
  hyprctl keyword cursor:inactive_timeout "$timeout_secs" >/dev/null
  rm "$STATE_FILE"
else
  hyprctl keyword cursor:inactive_timeout 0 >/dev/null
  touch "$STATE_FILE"
fi
