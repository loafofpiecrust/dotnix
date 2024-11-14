#!/usr/bin/env bash

LIGHT_THEME="$1"
DARK_THEME="$2"
SET_THEME="$3" # light or dark
if [[ "$SET_THEME" = "toggle" ]]; then
    CURRENT_GTK_SCHEME=$(gsettings get org.gnome.desktop.interface color-scheme)
    SET_THEME=$([[ "$CURRENT_GTK_SCHEME" = "'prefer-dark'" ]] && echo light || echo dark)
fi
THEME_FILE=$([[ "$SET_THEME" = "dark" ]] && echo "$DARK_THEME" || echo "$LIGHT_THEME")

# Use the color scheme in JSON as input for good ol' mustache templates!

mkdir -p ~/.config/colors/templates
mkdir -p ~/.cache/colors
ln -sf "$THEME_FILE" ~/.cache/colors/colors.json
for TEMPLATE in ~/.config/colors/templates/*; do
    mustache "$THEME_FILE" "$TEMPLATE" >"$HOME/.cache/colors/$(basename "$TEMPLATE")"
done

# Reload the programs that need reloading.
# GTK light/dark
GTK_PREFER_SCHEME=$([[ "$SET_THEME" = "dark" ]] && echo prefer-dark || echo prefer-light)
gsettings set org.gnome.desktop.interface color-scheme "$GTK_PREFER_SCHEME"
# Terminals
tee /dev/pts/[0-9]* <~/.cache/colors/sequences >/dev/null
# Window manager: sway
(swaymsg reload &)
# Notifications: mako
(makoctl reload &)
# Run the custom emacs command from the theme
EMACS_COMMAND=$(jq -rc '.commands.emacs' "$THEME_FILE")
emacsclient --eval "$EMACS_COMMAND" || true
