#!/usr/bin/env bash

BAT=$(echo /sys/class/power_supply/BAT*)
BAT_STATUS="$BAT/status"
BAT_CAP="$BAT/capacity"
LOW_BAT_PERCENT=25

AC_PROFILE="performance"
BAT_PROFILE="balanced"
LOW_BAT_PROFILE="power-saver"

sleep 10s

# start the monitor loop
prev=0

while true; do
    # read the current state
    # Keep the profile at AC if the battery is close to full because my dock
    # flips back and forth between charging and discharging.
    if [[ $(cat "$BAT_STATUS") == "Discharging" && $(cat "$BAT_CAP") -lt 88 ]]; then
        if [[ $(cat "$BAT_CAP") -gt $LOW_BAT_PERCENT ]]; then
            profile=$BAT_PROFILE
        else
            profile=$LOW_BAT_PROFILE
        fi
    else
        profile=$AC_PROFILE
    fi

    # set the new profile
    if [[ $prev != "$profile" ]]; then
        echo setting power profile to $profile
        powerprofilesctl set $profile
    fi

    prev=$profile

    # wait for the next power change event
    # Timeout every 30m to set the profile based on current battery level.
    inotifywait -t 1800 -qq "$BAT_STATUS" "$BAT_CAP"
done
