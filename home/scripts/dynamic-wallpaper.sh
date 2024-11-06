#!/usr/bin/env bash

CURRENT_TIME=$(date +%s)
BG_PREFIX="$3"
LIGHT_THEME="$4"
DARK_THEME="$5"

# Use sunwait to calculate sunrise/sunset times
get_sunrise=$(sunwait list civil rise "$1" "$2")
get_sunset=$(sunwait list civil set "$1" "$2")

# Use human-readable relative time for offset adjustments
presunrise=$(date -d "$get_sunrise 2 hours ago" +"%s")
sunrise=$(date -d "$get_sunrise" +"%s")
sunriseMid=$(date -d "$get_sunrise 15 minutes" +"%s")
sunriseLate=$(date -d "$get_sunrise 30 minutes" +"%s")
morning=$(date -d "$get_sunrise 90 minutes" +"%s")
afternoon=$(date -d "$get_sunrise 4 hours" +"%s")
twilightEarly=$(date -d "$get_sunset 90 minutes ago" +"%s")
twilightMid=$(date -d "$get_sunset 30 minutes ago" +"%s")
twilightLate=$(date -d "$get_sunset 15 minutes ago" +"%s")
sunset=$(date -d "$get_sunset" +"%s")
moonrise=$(date -d "$get_sunset 2 hours" +"%s")

## Wallpaper Display Logic
#1.jpg - after sunset until sunrise (sunset-sunrise)
#2.jpg - sunrise for 15 min (sunrise - sunriseMid)
#3.jpg - 15 min after sunrise for 15 min (sunriseMid-sunriseLate)
#4.jpg - 30 min after sunrise for 1 hour (sunriseLate-morning)
#        90 min after sunrise for 2.5 hr (morning-afternoon)
#5.jpg - day light between sunrise and sunset events (afternoon-twilightEarly)
#6.jpg - 1.5 hours before sunset for 1 hour (twilightEarly-twilightMid)
#7.jpg - 30 min before sunset for 15 min (twilightMid-twilightLate)
#8.jpg - 15 min before sunset for 15 min (twilightLate-sunset)

if [ "$CURRENT_TIME" -ge "$presunrise" ] && [ "$CURRENT_TIME" -lt "$sunrise" ]; then
    image=16
elif [ "$CURRENT_TIME" -ge "$sunrise" ] && [ "$CURRENT_TIME" -lt "$sunriseMid" ]; then
    image=1
elif [ "$CURRENT_TIME" -ge "$sunriseMid" ] && [ "$CURRENT_TIME" -lt "$sunriseLate" ]; then
    image=2
elif [ "$CURRENT_TIME" -ge "$sunriseLate" ] && [ "$CURRENT_TIME" -lt "$morning" ]; then
    image=4
elif [ "$CURRENT_TIME" -ge "$morning" ] && [ "$CURRENT_TIME" -lt "$afternoon" ]; then
    image=6
elif [ "$CURRENT_TIME" -ge "$afternoon" ] && [ "$CURRENT_TIME" -lt "$twilightEarly" ]; then
    image=8
elif [ "$CURRENT_TIME" -ge "$twilightEarly" ] && [ "$CURRENT_TIME" -lt "$twilightMid" ]; then
    image=10
elif [ "$CURRENT_TIME" -ge "$twilightMid" ] && [ "$CURRENT_TIME" -lt "$twilightLate" ]; then
    image=12
elif [ "$CURRENT_TIME" -ge "$twilightLate" ] && [ "$CURRENT_TIME" -lt "$sunset" ]; then
    image=13
elif [ "$CURRENT_TIME" -ge "$sunset" ] && [ "$CURRENT_TIME" -lt "$moonrise" ]; then
    image=14
else
    image=15
fi

# Only update the wallpaper if necessary to avoid extra costly animations.
OLD_IMAGE=$(swww query | cut -d' ' -f8)
NEW_IMAGE="${BG_PREFIX}$image.jpeg"
if [ "$NEW_IMAGE" != "$OLD_IMAGE" ]; then
    echo "$NEW_IMAGE"
    swww img --transition-duration 10 "$NEW_IMAGE"

    # Gammastep waits a LONG time into night before switching over my color scheme,
    # so let's do it here.
    CURRENT_THEME=$(gsettings get org.gnome.desktop.interface color-scheme)
    if [ "$CURRENT_TIME" -ge "$sunset" ] || [ "$CURRENT_TIME" -lt "$sunrise" ]; then
        if [ "$CURRENT_THEME" != "'prefer-dark'" ]; then
            gsettings set org.gnome.desktop.interface color-scheme prefer-dark
            wal -n -s -f "$DARK_THEME" &>/dev/null
            sleep 0.5s
            tee /dev/pts/[0-9]* <~/.cache/wal/base16-sequences >/dev/null
            makoctl reload
            emacsclient --eval "(+snead/load-theme 'night)" || true
        fi
    elif [ "$CURRENT_TIME" -ge "$sunrise" ]; then
        if [ "$CURRENT_THEME" != "'prefer-light'" ]; then
            gsettings set org.gnome.desktop.interface color-scheme prefer-light
            wal -n -s -f "$LIGHT_THEME" &>/dev/null
            sleep 0.5s
            tee /dev/pts/[0-9]* <~/.cache/wal/base16-sequences >/dev/null
            makoctl reload
            emacsclient --eval "(+snead/load-theme 'daytime)" || true
        fi
    fi
fi
