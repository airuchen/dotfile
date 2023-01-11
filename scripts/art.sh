#!/bin/bash

#put this file to ~/.ncmpcpp/

MUSIC_DIR=/mnt/music/ #path to your music dir

COVER=/tmp/cover.jpg

album="$(mpc --format %album% current)"
file="$(mpc --format %file% current)"
playing="$(mpc --format "%artist% \[%date% - %album%\] %track% - %title%" current)"
album_dir="${file%/*}"
[[ -z "$album_dir" ]] && exit 1
album_dir="$MUSIC_DIR/$album_dir"

covers="$(find "$album_dir" -type d -exec find {} -maxdepth 1 -type f -iregex ".*/.*\(${album}\|cover\|folder\|artwork\|front\).*[.]\(jpe?g\|png\|gif\|bmp\)" \; )"
src="$(echo -n "$covers" | head -n1)"
if [[ -n "$src" ]] ; then
  #resize the image's width to 300px 
  #convert "$src" -resize 300x "$COVER"
  #echo "${src}"
  feh --scale-down --info 'mpc | head -n1' -B black  --class feh_cover "${src}"
  #notify-send -i "${src}" "Now playing" "${playing}"
fi
