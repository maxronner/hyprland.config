#!/bin/sh

cursor=$1
normal_size=$2
big_size=$3

STATE_FILE="$XDG_RUNTIME_DIR/hypr-giant-cursor"

if [ -f "$STATE_FILE" ]; then
  hyprctl setcursor "$cursor" "$normal_size"
  rm "$STATE_FILE"
else
  hyprctl setcursor "$cursor" "$big_size"
  touch "$STATE_FILE"
fi
