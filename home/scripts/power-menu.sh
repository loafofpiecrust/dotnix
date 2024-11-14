#!/usr/bin/env sh

RESULT=$(printf "Shutdown\nReboot\nLog out" | rofi -dmenu -p "󰐥 ")
case $RESULT in
"Shutdown")
    shutdown now
    ;;
"Reboot")
    reboot
    ;;
"Log out")
    swaymsg exit
    ;;
esac
