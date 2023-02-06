#!/usr/bin/env sh

case $3 in
    night)
        gsettings set org.gnome.desktop.interface color-scheme prefer-dark;;
    daytime)
        gsettings set org.gnome.desktop.interface color-scheme prefer-light;;
esac
