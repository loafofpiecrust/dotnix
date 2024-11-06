#!/usr/bin/env sh
light $@
LIGHT=$(light -G)
LIGHT=$(printf "%.0f" "$LIGHT")
notify-send.sh "Brightness" -c overlay -h "int:value:$LIGHT" -R /tmp/overlay-notification
