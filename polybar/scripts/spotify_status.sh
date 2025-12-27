#!/bin/bash
status=$(playerctl status --player=spotify 2>/dev/null)
if [ "$status" = "Playing" ]; then
  echo "  $(playerctl metadata --player=spotify --format '{{artist}} - {{title}}')"
elif [ "$status" = "Paused" ]; then
  echo " $(playerctl metadata --player=spotify --format '{{artist}} - {{title}}')"
else
  echo " "
fi
