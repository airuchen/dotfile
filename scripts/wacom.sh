#!/bin/sh

DP_NAME=DP-3

xsetwacom set 'Wacom One by Wacom M Pen stylus' MapToOutput "${DP_NAME}"
xsetwacom set 'Wacom One by Wacom M Pen eraser' MapToOutput "${DP_NAME}"
xsetwacom set 'Wacom One by Wacom M Pen stylus' Area 0 0 21600 12150
xsetwacom set 'Wacom One by Wacom M Pen eraser' Area 0 0 21600 12150
