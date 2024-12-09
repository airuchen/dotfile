#! /usr/bin/env bash
# Cycles to the next layout
currlayout=$(hyprctl getoption general:layout | head -n1 | cut -f 2 -d\ )
layouts=$(hyprctl layouts; hyprctl layouts)
found=false
for l in $layouts; do
  if $found; then
    hyprctl keyword general:layout $l
    break
  fi
  if [ "${l}" == "${currlayout}" ]; then
    found=true
  fi
done
