#!/bin/bash

# Simple battery notification script for waybar
# Called by waybar when battery status updates

# Get battery info
battery_capacity=$(cat /sys/class/power_supply/BAT0/capacity 2>/dev/null || cat /sys/class/power_supply/BAT1/capacity 2>/dev/null)
battery_status=$(cat /sys/class/power_supply/BAT0/status 2>/dev/null || cat /sys/class/power_supply/BAT1/status 2>/dev/null)

# Only notify when discharging
if [[ "$battery_status" == "Discharging" ]]; then
    # Critical at 10% - red empty battery icon
    if [[ $battery_capacity -le 10 ]]; then
        notify-send -u critical "🪫 Battery Critical!" "Battery at ${battery_capacity}%\nPlug in charger now!" -t 0
    # Warning at 15% - plug icon
    elif [[ $battery_capacity -le 15 ]] && [[ $battery_capacity -gt 10 ]]; then
        notify-send -u normal "🔌 Battery Low" "Battery at ${battery_capacity}%\nConsider plugging in" -t 10000
    fi
fi

