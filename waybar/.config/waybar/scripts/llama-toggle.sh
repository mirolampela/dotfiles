#!/usr/bin/env bash
SERVICE="llama-server"

if systemctl --user is-active --quiet "$SERVICE"; then
    systemctl --user stop "$SERVICE"
else
    systemctl --user start "$SERVICE"
fi

# Refresh the Waybar module immediately
pkill -RTMIN+8 waybar
