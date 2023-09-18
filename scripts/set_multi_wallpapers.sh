#! /usr/bin/sh

set -e

num_screens=$(xrandr --listactivemonitors | sed 1d | wc -l)
wp_dir="${HOME}/Pictures/Wallpapers"
find "$wp_dir" -type f | shuf -n "$num_screens" | awk '{print "--bg-fill " $0}' | xargs -r feh
