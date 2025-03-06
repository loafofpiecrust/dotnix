#!/usr/bin/env sh
LIGHT=$(brightnessctl $@ -m | cut -d ',' -f4 | head -c-2)
notify-send.sh "Brightness" -c overlay -h "int:value:$LIGHT" -R /tmp/overlay-notification
