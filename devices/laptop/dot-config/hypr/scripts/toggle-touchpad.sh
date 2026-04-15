#!/usr/bin/env bash

keyword="device:touchpad:enabled"
state=$(hyprctl getoption "$keyword" -j | jq -r '.int')

if [ "$state" = "1" ]; then
  hyprctl keyword "$keyword" false
else
  hyprctl keyword "$keyword" true
fi
