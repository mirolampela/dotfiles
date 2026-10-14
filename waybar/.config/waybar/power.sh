#!/usr/bin/env bash

choice=$(printf "Shutdown\nReboot\nSuspend\nLock\nLog out" | fuzzel --dmenu --prompt "Power: " --lines 5 --width 20)

case "$choice" in
    "Shutdown") systemctl poweroff ;;
    "Reboot") systemctl reboot ;;
    "Suspend") systemctl suspend ;;
    "Lock") hyprlock ;;
    "Log out") hyprctl dispatch 'hl.dsp.exit()' ;;
esac
