#!/usr/bin/env bash
# Waybar app launcher: shows whether an app is running
# Usage: apps.sh <id>
#
# To add an app: add a line to APPS below:
#   [id]="Name|icon|process names (space separated)|command line pattern (optional)"
# The optional 4th field is matched against full command lines (pgrep -f),
# useful for Wine/Lutris apps. Then add a matching custom/<id> module to config.jsonc

declare -A APPS=(
    [steam]="Steam|"$'\uf1b6'"|steam|"
    [discord]="Discord|"$'\uf392'"|Discord discord|"
    [spotify]="Spotify|"$'\uf1bc'"|spotify|"
    [battlenet]="Battle.net|"$'\uf11b'"||lutris-wrapper Battle.net"
)

entry="${APPS[$1]}"
[[ -z "$entry" ]] && exit 1

IFS='|' read -r name icon procs pattern <<< "$entry"

# Right-click menus: apps.sh <id> menu
if [[ "$2" == "menu" ]]; then
    case "$1" in
        steam)
            choice=$(printf "Library\nStore\nFriends\nDownloads\nSettings\nExit Steam" \
                | fuzzel --dmenu --prompt "Steam: " --lines 6 --width 20)
            case "$choice" in
                "Library")    steam steam://open/games ;;
                "Store")      steam steam://store ;;
                "Friends")    steam steam://open/friends ;;
                "Downloads")  steam steam://open/downloads ;;
                "Settings")   steam steam://open/settings ;;
                "Exit Steam") steam steam://exit ;;
            esac
            ;;
        discord)
            choice=$(printf "Open\nFriends\nRestart Discord\nQuit Discord" \
                | fuzzel --dmenu --prompt "Discord: " --lines 4 --width 20)
            case "$choice" in
                "Open")            discord ;;
                "Friends")         discord "discord://-/channels/@me" ;;
                "Restart Discord") pkill -x Discord; sleep 2; setsid -f discord > /dev/null 2>&1 ;;
                "Quit Discord")    pkill -x Discord ;;
            esac
            ;;

    esac
    exit 0
fi

running=false
for p in $procs; do
    pgrep -x "$p" > /dev/null && running=true
done
if [[ -n "$pattern" ]] && pgrep -f "$pattern" > /dev/null; then
    running=true
fi

if $running; then
    printf '{"text": "%s", "class": "running", "tooltip": "%s is running"}\n' "$icon" "$name"
else
    printf '{"text": "%s", "class": "stopped", "tooltip": "Click to start %s"}\n' "$icon" "$name"
fi
