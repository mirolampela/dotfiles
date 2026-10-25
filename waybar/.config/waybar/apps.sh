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
    [battlenet]="Battle.net|"$'\uf11b'"||lutris-wrapper Battle.net"
)

entry="${APPS[$1]}"
[[ -z "$entry" ]] && exit 1

IFS='|' read -r name icon procs pattern <<< "$entry"

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
