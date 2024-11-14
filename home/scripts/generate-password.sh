#!/usr/bin/env bash

ENTRY_NAME=$(rofi -dmenu -l 0 -p "Create account for")
if [[ "$ENTRY_NAME" =~ ^(https?://)?[a-z1-9]+(\.[a-z1-9]+)+$ ]]; then
    ENTRY_URI="$ENTRY_NAME"
else
    ENTRY_URI=$(rofi -dmenu -l 0 -p "URI")
fi
ENTRY_USERNAME=$(rofi -dmenu -l 0 -p "Username")
ENTRY_PASSWORD=$(rbw generate --uri "$ENTRY_URI" 30 "$ENTRY_NAME" "$ENTRY_USERNAME")
echo "type $ENTRY_PASSWORD" | dotool
